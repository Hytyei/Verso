// verso-api: sync server for the Verso app (single owner).
//
// Auth: every request carries `Authorization: Bearer <Google ID token>`. The token's RS256 signature is checked
// against Google's keys, plus iss, exp and aud (GOOGLE_CLIENT_ID, a comma list). The first Google account ("sub")
// that calls the API becomes the owner; any other account gets 403.
//
// Data: one generic `rows` table. POST /v1/sync pushes rows (last write by updated_at wins) and pulls rows whose
// server sequence number is greater than the client's cursor. Images live in D1 as 1 MB chunks (/v1/blobs/:name).

export interface Env {
  DB: D1Database;
  GOOGLE_CLIENT_ID?: string;
}

export type Identity = { sub: string; email: string };
export type Verifier = (env: Env, token: string) => Promise<Identity>;

export class HttpError extends Error {
  constructor(public status: number, message: string) {
    super(message);
  }
}

const enc = new TextEncoder();
// Free-plan Workers allow ~50 D1 queries per request: auth (2) + pull (1) + up to 40 row writes.
const MAX_PUSH = 40;
const PAGE = 500;
const CHUNK = 1024 * 1024;
const MAX_BLOB = 40 * 1024 * 1024;
const TABLES = new Set([
  "projects", "environments", "versions", "features", "subitems", "milestones", "tags", "feature_tags", "attachments",
]);
const BLOB_NAME = /^[0-9a-f-]{36}\.(png|jpg|jpeg|gif|webp|bmp)$/;

function json(data: unknown, status = 200): Response {
  return new Response(JSON.stringify(data), { status, headers: { "content-type": "application/json; charset=utf-8" } });
}

function b64uDecode(s: string): Uint8Array {
  const b = atob(s.replace(/-/g, "+").replace(/_/g, "/") + "===".slice((s.length + 3) % 4));
  const out = new Uint8Array(b.length);
  for (let i = 0; i < b.length; i++) out[i] = b.charCodeAt(i);
  return out;
}

// ------------------------------------------------------------------ Google ID token
let keyCache: { at: number; keys: any[] } | null = null;
async function googleKeys(force = false): Promise<any[]> {
  if (!force && keyCache && Date.now() - keyCache.at < 3600_000) return keyCache.keys;
  const r = await fetch("https://www.googleapis.com/oauth2/v3/certs");
  if (!r.ok) throw new HttpError(502, "Couldn't reach Google to check the sign-in");
  const j: any = await r.json();
  keyCache = { at: Date.now(), keys: Array.isArray(j.keys) ? j.keys : [] };
  return keyCache.keys;
}

export const verifyGoogle: Verifier = async (env, token) => {
  const audiences = (env.GOOGLE_CLIENT_ID ?? "").split(",").map((s) => s.trim()).filter(Boolean);
  if (audiences.length === 0) throw new HttpError(501, "Google sign-in isn't configured on this server");
  if (token.length < 40 || token.length > 4096) throw new HttpError(401, "Invalid sign-in");
  const parts = token.split(".");
  if (parts.length !== 3) throw new HttpError(401, "Invalid sign-in");
  let header: any, claims: any;
  try {
    header = JSON.parse(new TextDecoder().decode(b64uDecode(parts[0])));
    claims = JSON.parse(new TextDecoder().decode(b64uDecode(parts[1])));
  } catch {
    throw new HttpError(401, "Invalid sign-in");
  }
  if (header.alg !== "RS256" || typeof header.kid !== "string") throw new HttpError(401, "Invalid sign-in");
  let jwk = (await googleKeys()).find((k) => k.kid === header.kid);
  if (!jwk) jwk = (await googleKeys(true)).find((k) => k.kid === header.kid);
  if (!jwk) throw new HttpError(401, "Invalid sign-in");
  const key = await crypto.subtle.importKey("jwk", jwk, { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" }, false, ["verify"]);
  const okSig = await crypto.subtle.verify("RSASSA-PKCS1-v1_5", key, b64uDecode(parts[2]), enc.encode(`${parts[0]}.${parts[1]}`));
  if (!okSig) throw new HttpError(401, "Invalid sign-in");
  const nowSec = Math.floor(Date.now() / 1000);
  const issOk = claims.iss === "https://accounts.google.com" || claims.iss === "accounts.google.com";
  if (!issOk || !audiences.includes(claims.aud) || typeof claims.exp !== "number" || claims.exp < nowSec - 30 || typeof claims.sub !== "string" || !claims.sub)
    throw new HttpError(401, "Sign-in is invalid or expired");
  return { sub: claims.sub, email: typeof claims.email === "string" ? claims.email : "" };
};

// ------------------------------------------------------------------ owner
async function authorize(req: Request, env: Env, verify: Verifier): Promise<Identity> {
  const h = req.headers.get("authorization") ?? "";
  const m = /^Bearer (.+)$/.exec(h);
  if (!m) throw new HttpError(401, "Sign in to sync");
  const id = await verify(env, m[1].trim());
  // The first account to arrive claims the server.
  await env.DB.prepare("INSERT OR IGNORE INTO meta (k, v) VALUES ('owner_sub', ?)").bind(id.sub).run();
  const owner = await env.DB.prepare("SELECT v FROM meta WHERE k = 'owner_sub'").first<{ v: string }>();
  if (!owner || owner.v !== id.sub) throw new HttpError(403, "This Verso server belongs to another account");
  return id;
}

// ------------------------------------------------------------------ sync
type WireRow = { t: string; id: string; u: number; d: boolean; data: Record<string, unknown> };

function validRow(r: any): r is WireRow {
  return (
    r && typeof r === "object" && typeof r.t === "string" && TABLES.has(r.t) && typeof r.id === "string" &&
    r.id.length > 0 && r.id.length <= 120 && Number.isFinite(r.u) && typeof r.d === "boolean" &&
    r.data && typeof r.data === "object" && !Array.isArray(r.data)
  );
}

async function sync(req: Request, env: Env): Promise<Response> {
  let body: any;
  try {
    body = await req.json();
  } catch {
    throw new HttpError(400, "Body must be JSON");
  }
  const cursor = Number.isFinite(body?.cursor) ? Math.max(0, Math.floor(body.cursor)) : 0;
  const rows: unknown[] = Array.isArray(body?.rows) ? body.rows : [];
  if (rows.length > MAX_PUSH) throw new HttpError(413, `Push at most ${MAX_PUSH} rows at a time`);
  const accepted: string[] = [];
  const stmts: D1PreparedStatement[] = [];
  for (const r of rows) {
    if (!validRow(r)) throw new HttpError(400, "Malformed row");
    const data = JSON.stringify(r.data);
    if (data.length > 1_000_000) throw new HttpError(413, "Row too large");
    // Insert, or replace only when strictly newer. Each accepted write takes the next sequence number.
    stmts.push(
      env.DB.prepare(
        `INSERT INTO rows (tbl, id, updated_at, deleted, data, seq)
         VALUES (?1, ?2, ?3, ?4, ?5, (SELECT COALESCE(MAX(seq), 0) + 1 FROM rows))
         ON CONFLICT (tbl, id) DO UPDATE SET
           updated_at = excluded.updated_at, deleted = excluded.deleted, data = excluded.data,
           seq = (SELECT COALESCE(MAX(seq), 0) + 1 FROM rows)
         WHERE excluded.updated_at > rows.updated_at`,
      ).bind(r.t, r.id, Math.floor(r.u), r.d ? 1 : 0, data),
    );
    accepted.push(`${r.t}:${r.id}`);
  }
  if (stmts.length) await env.DB.batch(stmts);
  const page = await env.DB.prepare(
    "SELECT tbl, id, updated_at, deleted, data, seq FROM rows WHERE seq > ? ORDER BY seq LIMIT ?",
  ).bind(cursor, PAGE + 1).all<any>();
  const results = page.results ?? [];
  const more = results.length > PAGE;
  const out = results.slice(0, PAGE);
  const next = out.length ? Number(out[out.length - 1].seq) : cursor;
  return json({
    cursor: next,
    more,
    pushed: accepted.length,
    rows: out.map((x) => ({ t: x.tbl, id: x.id, u: Number(x.updated_at), d: !!x.deleted, data: JSON.parse(x.data) })),
  });
}

// ------------------------------------------------------------------ blobs
async function putBlob(name: string, req: Request, env: Env): Promise<Response> {
  const buf = new Uint8Array(await req.arrayBuffer());
  if (buf.length === 0) throw new HttpError(400, "Empty upload");
  if (buf.length > MAX_BLOB) throw new HttpError(413, "Images over 40 MB are not supported");
  const chunks = Math.ceil(buf.length / CHUNK);
  const stmts: D1PreparedStatement[] = [env.DB.prepare("DELETE FROM blob_chunks WHERE name = ?").bind(name)];
  for (let i = 0; i < chunks; i++) {
    stmts.push(env.DB.prepare("INSERT INTO blob_chunks (name, idx, bytes) VALUES (?, ?, ?)").bind(name, i, buf.slice(i * CHUNK, (i + 1) * CHUNK)));
  }
  stmts.push(
    env.DB.prepare("INSERT OR REPLACE INTO blob_meta (name, size, chunks, created_at) VALUES (?, ?, ?, ?)").bind(name, buf.length, chunks, Date.now()),
  );
  await env.DB.batch(stmts);
  return json({ name, size: buf.length }, 201);
}

async function getBlob(name: string, env: Env, headOnly: boolean): Promise<Response> {
  const meta = await env.DB.prepare("SELECT size, chunks FROM blob_meta WHERE name = ?").bind(name).first<{ size: number; chunks: number }>();
  if (!meta) return new Response(null, { status: 404 });
  if (headOnly) return new Response(null, { status: 200, headers: { "content-length": String(meta.size) } });
  const out = new Uint8Array(meta.size);
  let at = 0;
  for (let i = 0; i < meta.chunks; i++) {
    const c = await env.DB.prepare("SELECT bytes FROM blob_chunks WHERE name = ? AND idx = ?").bind(name, i).first<{ bytes: ArrayBuffer | Uint8Array }>();
    if (!c) throw new HttpError(500, "Blob is incomplete");
    const bytes = c.bytes instanceof Uint8Array ? c.bytes : new Uint8Array(c.bytes);
    out.set(bytes, at);
    at += bytes.length;
  }
  return new Response(out, { status: 200, headers: { "content-type": "application/octet-stream" } });
}

// ------------------------------------------------------------------ router
export function createHandler(verify: Verifier) {
  return async (req: Request, env: Env): Promise<Response> => {
    const url = new URL(req.url);
    try {
      if (url.pathname === "/v1/health") return json({ ok: true, service: "verso-api" });
      await authorize(req, env, verify);
      if (url.pathname === "/v1/sync" && req.method === "POST") return await sync(req, env);
      const m = /^\/v1\/blobs\/([^/]+)$/.exec(url.pathname);
      if (m) {
        const name = decodeURIComponent(m[1]);
        if (!BLOB_NAME.test(name)) throw new HttpError(400, "Bad blob name");
        if (req.method === "PUT") return await putBlob(name, req, env);
        if (req.method === "GET") return await getBlob(name, env, false);
        if (req.method === "HEAD") return await getBlob(name, env, true);
      }
      return json({ error: "Not found" }, 404);
    } catch (e) {
      if (e instanceof HttpError) return json({ error: e.message }, e.status);
      return json({ error: "Server error" }, 500);
    }
  };
}

const handle = createHandler(verifyGoogle);
export default { fetch: (req: Request, env: Env) => handle(req, env) };
