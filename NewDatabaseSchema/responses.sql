CREATE TABLE responses (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    endpoint_id INTEGER NOT NULL,
    status_code INTEGER NOT NULL,
    latency_ms REAL NOT NULL,
    timestamp DATETIME NOT NULL,
    total_hits INTEGER NOT NULL DEFAULT 1,
    avg_latency REAL NOT NULL,
    last_updated DATETIME NOT NULL,
    body_size INTEGER NOT NULL,
    body_size_min INTEGER NOT NULL,
    body_size_max INTEGER NOT NULL,
    content_type TEXT,
    error_ratio REAL NOT NULL DEFAULT 0,
    UNIQUE(endpoint_id, status_code),
    FOREIGN KEY(endpoint_id) REFERENCES endpoints(id)
);


//CREATE INDEX idx_responses_endpoint_status ON responses (endpoint_id, status_code);
