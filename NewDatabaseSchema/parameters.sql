CREATE TABLE parameters (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  endpoint_id INTEGER NOT NULL,              -- FK to endpoints.id
  name TEXT NOT NULL,                         -- e.g., "header.User-Agent", "username"
  type TEXT,                                  -- string | number | boolean | array | object
  min_val TEXT,                               -- lowest observed value (stringified)
  max_val TEXT,                               -- highest observed value (stringified)
  frequency INTEGER NOT NULL DEFAULT 0,       -- how often seen
  min_length INTEGER,                         -- shortest observed value length
  max_length INTEGER,                         -- longest observed value length
  avg_length REAL NOT NULL DEFAULT 0.0,       -- rolling average length
  entropy_score REAL NOT NULL DEFAULT 0.0,    -- rolling average entropy
  first_seen DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  last_seen DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  observed_values TEXT,                       -- JSON array of sample values
  allowed_values TEXT,                        -- JSON array of expected values (manual/configured)
  anomaly_count INTEGER NOT NULL DEFAULT 0,   -- count of anomalies detected for this param
  FOREIGN KEY (endpoint_id) REFERENCES endpoints(id),
  UNIQUE(endpoint_id, name)                   -- avoid duplicates for same endpoint
);

CREATE INDEX idx_parameters_endpoint ON parameters (endpoint_id);
