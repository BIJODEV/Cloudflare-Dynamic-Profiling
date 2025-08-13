CREATE TABLE responses (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    endpoint_id INTEGER NOT NULL REFERENCES endpoints(id),
    status_code INTEGER NOT NULL,
    content_type TEXT,
    avg_size INTEGER DEFAULT 0,    -- in bytes
    avg_latency_ms REAL DEFAULT 0.0,
    error_ratio REAL DEFAULT 0.0,  -- % of 4xx/5xx
    first_seen TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_seen TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    FOREIGN KEY(endpoint_id) REFERENCES endpoints(id),
    UNIQUE(endpoint_id, status_code)
);

//CREATE INDEX idx_responses_endpoint_status ON responses (endpoint_id, status_code);
