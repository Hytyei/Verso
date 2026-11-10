-- verso-api D1 schema (single owner).
CREATE TABLE IF NOT EXISTS meta (k TEXT PRIMARY KEY, v TEXT NOT NULL);

-- Every synced app row, whatever its table. Last write (by updated_at) wins.
CREATE TABLE IF NOT EXISTS rows (
  tbl TEXT NOT NULL,
  id TEXT NOT NULL,
  updated_at INTEGER NOT NULL,
  deleted INTEGER NOT NULL DEFAULT 0,
  data TEXT NOT NULL,
  seq INTEGER NOT NULL,
  PRIMARY KEY (tbl, id)
);
CREATE INDEX IF NOT EXISTS rows_seq ON rows(seq);

-- Attachment images (R2 is not enabled on the account): 1 MB chunks.
CREATE TABLE IF NOT EXISTS blob_meta (name TEXT PRIMARY KEY, size INTEGER NOT NULL, chunks INTEGER NOT NULL, created_at INTEGER NOT NULL);
CREATE TABLE IF NOT EXISTS blob_chunks (name TEXT NOT NULL, idx INTEGER NOT NULL, bytes BLOB NOT NULL, PRIMARY KEY (name, idx));
