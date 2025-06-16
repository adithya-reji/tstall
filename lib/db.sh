#!/usr/bin/env bash

DB_FILE="$HOME/.tstall/tstall.db"

init_db() {
    if [ ! -f "$DB_FILE" ]; then
        mkdir -p "$(dirname "$DB_FILE")"
        echo "Initializing database at $DB_FILE"
        sqlite3 "$DB_FILE" <<EOF
CREATE TABLE IF NOT EXISTS installed_packages (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    manager TEXT NOT NULL,
    version TEXT,
    label TEXT,
    installed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
EOF
    fi
}