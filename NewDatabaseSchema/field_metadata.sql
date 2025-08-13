CREATE TABLE field_metadata (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    endpoint_id INTEGER NOT NULL REFERENCES endpoints(id),
    field_name TEXT NOT NULL,        -- e.g., "Content-Type", "username"
    field_location TEXT NOT NULL,    -- header, body, query, cookie
    data_type TEXT,                  -- string, number, boolean, array, object
    avg_length REAL DEFAULT 0.0,
    avg_entropy REAL DEFAULT 0.0,
    is_sensitive BOOLEAN DEFAULT 0,  -- e.g., password, token
    last_seen TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (endpoint_id) REFERENCES endpoints(id)
    UNIQUE(endpoint_id, field_name, field_location) -- Avoid duplicates for same field
);

CREATE INDEX idx_field_metadata_endpoint ON field_metadata (endpoint_id);
