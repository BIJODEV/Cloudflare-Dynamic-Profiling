CREATE TABLE parameters (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  endpoint_id INTEGER,
  name TEXT NOT NULL,
  type TEXT,
  min_val TEXT,
  max_val TEXT,
  frequency INTEGER DEFAULT 1,
  FOREIGN KEY(endpoint_id) REFERENCES endpoints(id),
  UNIQUE(endpoint_id, name)
);
