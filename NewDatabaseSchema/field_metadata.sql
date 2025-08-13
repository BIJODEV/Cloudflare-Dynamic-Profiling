CREATE TABLE field_metadata (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  endpoint_id INTEGER NOT NULL,              -- FK to endpoints.id
  field_name TEXT NOT NULL,                  -- e.g., "username", "Content-Type"
  data_type TEXT,                            -- string | number | boolean | array | object
  is_required INTEGER NOT NULL DEFAULT 0,    -- 0/1
  is_readonly INTEGER NOT NULL DEFAULT 0,    -- 0/1
  format TEXT,                               -- email | uuid | date | etc.
  example_value TEXT,
  first_seen DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  last_seen  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  seen_count INTEGER NOT NULL DEFAULT 0,
  required_ratio REAL NOT NULL DEFAULT 0.0,  -- seen_count / endpoint.total_hits (approx)
  field_source TEXT NOT NULL,                -- 'body' | 'header' | 'query' | 'cookie'
  min_length INTEGER,
  max_length INTEGER,
  avg_length REAL NOT NULL DEFAULT 0.0,
  entropy_score REAL NOT NULL DEFAULT 0.0,
  FOREIGN KEY (endpoint_id) REFERENCES endpoints(id),
  UNIQUE(endpoint_id, field_name)            -- matches your WHERE endpoint_id & name
);

CREATE INDEX idx_field_metadata_endpoint ON field_metadata (endpoint_id);
