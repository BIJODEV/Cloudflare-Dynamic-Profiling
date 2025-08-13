CREATE TABLE request_metrics (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  endpoint_id INTEGER NOT NULL,
  timestamp DATETIME NOT NULL,
  request_hash TEXT NOT NULL,
  body_size INTEGER NOT NULL,
  query_count INTEGER NOT NULL,
  body_field_count INTEGER NOT NULL,
  header_count INTEGER NOT NULL,
  cookie_count INTEGER NOT NULL,
  cookie_count_bucket TEXT NOT NULL,
  burst_count INTEGER NOT NULL,
  latency_histogram TEXT NOT NULL, -- Stored as JSON
  header_size INTEGER NOT NULL,
  query_length INTEGER NOT NULL,
  FOREIGN KEY (endpoint_id) REFERENCES endpoints(id)
  UNIQUE(endpoint_id, request_hash)
);
