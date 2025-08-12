CREATE TABLE field_metadata (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  endpoint_id INTEGER NOT NULL,
  field_name TEXT NOT NULL,
  data_type TEXT,
  is_required INTEGER DEFAULT 0,
  is_readonly INTEGER DEFAULT 0,
  format TEXT,
  example_value TEXT,
  description TEXT,
  first_seen TEXT,             -- ISO timestamp when field was first seen
  last_seen TEXT,              -- ISO timestamp when field was last seen
  seen_count INTEGER DEFAULT 1,    -- Number of times field was seen
  required_ratio REAL DEFAULT 1.0, -- Ratio of times field was present vs total hits
  field_source TEXT DEFAULT 'body', -- Source: body, query, header, etc.

  UNIQUE(endpoint_id, field_name),
  FOREIGN KEY(endpoint_id) REFERENCES endpoints(id)
);
