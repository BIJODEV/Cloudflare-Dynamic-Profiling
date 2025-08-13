CREATE TABLE parameters (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    endpoint_id INTEGER NOT NULL REFERENCES endpoints(id),
    param_name TEXT NOT NULL,
    param_location TEXT NOT NULL,    -- query, body, cookie
    observed_values TEXT,            -- optional, comma-separated recent values
    avg_length REAL DEFAULT 0.0,
    avg_entropy REAL DEFAULT 0.0,
    last_seen TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (endpoint_id) REFERENCES endpoints(id)
    UNIQUE(endpoint_id, param_name, param_location) -- Avoid duplicates
);

CREATE INDEX idx_parameters_endpoint ON parameters (endpoint_id);
