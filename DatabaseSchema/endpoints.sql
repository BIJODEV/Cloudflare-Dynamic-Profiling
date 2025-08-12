CREATE TABLE endpoints ( 
    id INTEGER PRIMARY KEY AUTOINCREMENT, 
    path TEXT NOT NULL, 
    method TEXT NOT NULL, 
    last_seen TEXT, 
    UNIQUE(path, method) 
    )