CREATE TABLE endpoints (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    host TEXT NOT NULL,                       -- host for the endpoint
    path TEXT NOT NULL,                       -- URI path without query
    method TEXT NOT NULL,                     -- GET, POST, etc.
    url_pattern TEXT,                         -- normalized/templated path pattern
    description TEXT,                         -- Optional: endpoint purpose
    first_seen TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_seen TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    hit_count INTEGER DEFAULT 0,              -- hits since first_seen
    total_hits INTEGER DEFAULT 0,             -- total hits for ratio calculations
    content_type TEXT,                        -- last seen Content-Type
    auth_required_ratio REAL DEFAULT 0.0,     -- % authenticated requests
    error_rate REAL DEFAULT 0.0,              -- % 4xx/5xx errors
    UNIQUE(host, path, method)                -- prevent duplicate endpoints
);

//CREATE INDEX idx_endpoints_host_path ON endpoints (host, path);
