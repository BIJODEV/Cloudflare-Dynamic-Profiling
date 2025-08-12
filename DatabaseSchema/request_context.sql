CREATE TABLE request_context ( 
    id INTEGER PRIMARY KEY AUTOINCREMENT, 
    endpoint_id INTEGER, 
    timestamp TEXT, 
    ip TEXT, 
    geo TEXT, 
    user_agent TEXT, 
    intent TEXT, 
    method TEXT, 
    FOREIGN KEY(endpoint_id) REFERENCES endpoints(id) 
    )