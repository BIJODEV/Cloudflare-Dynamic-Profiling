CREATE TABLE request_context (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    endpoint_id INTEGER NOT NULL,
    timestamp DATETIME NOT NULL,
    ip TEXT NOT NULL,
    geo TEXT,
    user_agent TEXT,
    intent TEXT,
    method TEXT NOT NULL,
    auth_status TEXT,
    protocol_version TEXT,
    tls_version TEXT,
    tls_cipher TEXT,
    referrer TEXT,
    asn TEXT,
    content_type TEXT,
    accept_header TEXT,
    
    -- Ensure only one row per endpoint+method+ip
    UNIQUE(endpoint_id, method, ip),
    FOREIGN KEY(endpoint_id) REFERENCES endpoints(id) 

);


//CREATE INDEX idx_request_context_endpoint_ip ON request_context (endpoint_id, ip);