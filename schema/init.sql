CREATE TABLE IF NOT EXISTS installed_packages (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    manager TEXT NOT NULL,
    version TEXT,
    label TEXT,
    installed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);