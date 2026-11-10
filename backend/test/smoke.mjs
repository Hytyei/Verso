// Runs the Worker against an in-memory SQLite that mimics D1 (node:sqlite).
import { DatabaseSync } from "node:sqlite";
import fs from "node:fs";

const mod = await import(new URL("../src/index.ts", import.meta.url).href);
const sqlite = new DatabaseSync(":memory:");
sqlite.exec(fs.readFileSync(new URL("../schema.sql", import.meta.url), "utf8"));
const norm = (v) => (v instanceof ArrayBuffer ? new Uint8Array(v) : v);
class Stmt {
  constructor(sql) { this.sql = sql; this.args = []; }
  bind(...a) { this.args = a.map(norm); return this; }
  async first() { return sqlite.prepare(this.sql).get(...this.args) ?? null; }
  async all() { return { results: sqlite.prepare(this.sql).all(...this.args), meta: {} }; }
  async run() { const r = sqlite.prepare(this.sql).run(...this.args); return { results: [], meta: { changes: Number(r.changes) } }; }
}
const DB = {
  prepare: (q) => new Stmt(q),
  async batch(ss) { sqlite.exec("BEGIN"); try { const out = []; for (const s of ss) out.push(await s.run()); sqlite.exec("COMMIT"); return out; } catch (e) { sqlite.exec("ROLLBACK"); throw e; } },
};
const env = { DB, GOOGLE_CLIENT_ID: "test" };
// Test verifier: "tok-<sub>" signs in as <sub>.
const handle = mod.createHandler(async (_env, token) => {
  if (!token.startsWith("tok-")) { throw new mod.HttpError(401, "Invalid sign-in"); }
  return { sub: token.slice(4), email: "" };
});
const call = async (method, path, token, body, raw) => {
  const headers = {}; if (token) headers.authorization = "Bearer " + token;
  let b; if (raw) b = raw; else if (body) { b = JSON.stringify(body); headers["content-type"] = "application/json"; }
  const r = await handle(new Request("https://x" + path, { method, headers, body: b }), env);
  const ct = r.headers.get("content-type") || "";
  return { status: r.status, body: ct.includes("json") ? await r.json() : new Uint8Array(await r.arrayBuffer()) };
};
let fails = 0;
const ok = (name, cond, extra) => { console.log((cond ? "PASS " : "FAIL ") + name + (cond ? "" : " " + JSON.stringify(extra))); if (!cond) fails++; };
const row = (t, id, u, data = {}, d = false) => ({ t, id, u, d, data: { id, updatedAt: u, ...data } });

let r = await call("GET", "/v1/health");
ok("health is public", r.status === 200 && r.body.ok, r);
r = await call("POST", "/v1/sync", null, { cursor: 0, rows: [] });
ok("no token 401", r.status === 401, r);
r = await call("POST", "/v1/sync", "garbage", { cursor: 0, rows: [] });
ok("bad token 401", r.status === 401, r);

r = await call("POST", "/v1/sync", "tok-owner", { cursor: 0, rows: [row("projects", "p1", 100, { name: "Tandem" }), row("features", "f1", 100, { title: "A" })] });
ok("first account claims and pushes", r.status === 200 && r.body.pushed === 2 && r.body.rows.length === 2, r);
const c1 = r.body.cursor;
r = await call("POST", "/v1/sync", "tok-intruder", { cursor: 0, rows: [] });
ok("second account 403", r.status === 403, r);

r = await call("POST", "/v1/sync", "tok-owner", { cursor: c1, rows: [row("projects", "p1", 50, { name: "older" })] });
ok("older write is ignored", r.status === 200 && r.body.rows.length === 0 && r.body.cursor === c1, r);
r = await call("POST", "/v1/sync", "tok-owner", { cursor: c1, rows: [row("projects", "p1", 100, { name: "same time" })] });
ok("equal timestamp keeps stored row", r.body.rows.length === 0, r);
r = await call("POST", "/v1/sync", "tok-owner", { cursor: c1, rows: [row("projects", "p1", 200, { name: "Tandem 2" })] });
ok("newer write wins and comes back with a new seq", r.body.rows.length === 1 && r.body.rows[0].data.name === "Tandem 2" && r.body.cursor > c1, r);
r = await call("POST", "/v1/sync", "tok-owner", { cursor: 0, rows: [row("features", "f1", 300, {}, true)] });
ok("soft delete travels as a row", r.body.rows.find((x) => x.id === "f1").d === true, r);
r = await call("POST", "/v1/sync", "tok-owner", { cursor: 0, rows: [{ t: "nope", id: "x", u: 1, d: false, data: {} }] });
ok("unknown table 400", r.status === 400, r);

// Paging: 1203 rows come back over 3 pages in seq order.
const many = []; for (let i = 0; i < 1203; i++) many.push(row("subitems", "s" + i, 1000 + i));
let pushOk = true;
for (let i = 0; i < many.length; i += 40) { r = await call("POST", "/v1/sync", "tok-owner", { cursor: 0, rows: many.slice(i, i + 40) }); pushOk &&= r.status === 200; }
ok("push in batches of 40", pushOk, r.status);
let cursor = 0, seen = 0, pages = 0, more = true;
while (more) { r = await call("POST", "/v1/sync", "tok-owner", { cursor, rows: [] }); seen += r.body.rows.length; cursor = r.body.cursor; more = r.body.more; pages++; }
ok("pull pages until done", seen === 1205 && pages === 3, { seen, pages });
r = await call("POST", "/v1/sync", "tok-owner", { cursor: 0, rows: many.slice(0, 41) });
ok("push over 40 rejected", r.status === 413, r.status);

// Blobs: 2.5 MB image round-trips through 1 MB chunks.
const name = "0f8fad5b-d9cb-469f-a165-70867728950e.png";
const img = new Uint8Array(2.5 * 1024 * 1024); for (let i = 0; i < img.length; i++) img[i] = i % 251;
r = await call("HEAD", "/v1/blobs/" + name, "tok-owner");
ok("missing blob 404", r.status === 404, r.status);
r = await call("PUT", "/v1/blobs/" + name, "tok-owner", null, img);
ok("upload blob", r.status === 201 && r.body.size === img.length, r);
r = await call("GET", "/v1/blobs/" + name, "tok-owner");
ok("download blob intact", r.status === 200 && r.body.length === img.length && r.body[12345] === img[12345] && r.body[img.length - 1] === img[img.length - 1], r.body.length);
r = await call("PUT", "/v1/blobs/..%2Fetc.png", "tok-owner", null, img);
ok("bad blob name 400", r.status === 400, r.status);
r = await call("GET", "/v1/blobs/" + name, "tok-intruder");
ok("intruder cannot read blobs", r.status === 403, r.status);

console.log(fails ? `${fails} FAILED` : "ALL PASS");
process.exit(fails ? 1 : 0);
