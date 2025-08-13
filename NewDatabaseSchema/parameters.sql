CREATE TABLE parameters (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  endpoint_id INTEGER NOT NULL,              -- FK to endpoints.id
  name TEXT NOT NULL,                        -- e.g., "User-Agent", "username"
  location TEXT NOT NULL,                    -- 'body', 'query', 'header', etc.
  type TEXT,                                 -- string | number | boolean | array | object
  min_val TEXT,
  max_val TEXT,
  frequency INTEGER NOT NULL DEFAULT 0,
  min_length INTEGER,
  max_length INTEGER,
  avg_length REAL NOT NULL DEFAULT 0.0,
  entropy_score REAL NOT NULL DEFAULT 0.0,
  first_seen DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  last_seen DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  observed_values TEXT,
  allowed_values TEXT,
  anomaly_count INTEGER NOT NULL DEFAULT 0,
  FOREIGN KEY (endpoint_id) REFERENCES endpoints(id),
  UNIQUE(endpoint_id, name, location)        -- ✅ matches your ON CONFLICT clause
);


CREATE INDEX idx_parameters_endpoint ON parameters (endpoint_id);
