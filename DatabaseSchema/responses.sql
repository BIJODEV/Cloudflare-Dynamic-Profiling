CREATE TABLE responses (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  endpoint_id INTEGER,
  status_code INTEGER,
  latency_ms REAL,
  timestamp TEXT,
  total_hits INTEGER DEFAULT 1,
  avg_latency REAL DEFAULT 0,
  last_updated TEXT,
  FOREIGN KEY(endpoint_id) REFERENCES endpoints(id),
  UNIQUE(endpoint_id, status_code)
);