CREATE TABLE request_metrics (
  endpoint_id INTEGER,
  timestamp TEXT,
  body_size INTEGER,
  query_count INTEGER,
  body_field_count INTEGER,
  header_count INTEGER,
  cookie_count INTEGER,
  cookie_count_bucket TEXT
  FOREIGN KEY(endpoint_id) REFERENCES endpoints(id)
  UNIQUE(endpoint_id, cookie_count_bucket)
);
