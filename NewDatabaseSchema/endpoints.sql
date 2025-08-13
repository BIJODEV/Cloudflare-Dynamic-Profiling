CREATE TABLE endpoints (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    method TEXT NOT NULL,           -- GET, POST, etc.
    host TEXT NOT NULL,
    path TEXT NOT NULL,             -- URI path without query
    description TEXT,               -- Optional: purpose of this endpoint
    first_seen TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_seen TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    request_count INTEGER DEFAULT 0,
    UNIQUE(method, host, path)      -- Prevent duplicate endpoint entries
);

//CREATE INDEX idx_endpoints_host_path ON endpoints (host, path);