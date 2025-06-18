#!/usr/bin/env bash

# DB_FILE="$HOME/.tstall/tstall.db"
DB_FILE="tstall.db"

init_db() {
    # if [ ! -f "$DB_FILE" ]; then
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
    # fi
}

add_dummy_data() {
    sqlite3 "$DB_FILE" <<EOF
INSERT INTO installed_packages (name, manager, version, label)
VALUES ('jump', 'apt', '2.0.0', 'opensource');
INSERT INTO installed_packages (name, manager, version, label)
VALUES ('walk', 'snap', '2.0.1', 'tech');
INSERT INTO installed_packages (name, manager, version, label)
VALUES ('dance', 'apt', '2.5.0', 'python');
INSERT INTO installed_packages (name, manager, version, label)
VALUES ('yelo', 'apt-get', '2.4.0', 'test');
INSERT INTO installed_packages (name, manager, version, label)
VALUES ('can', 'apt', '2.1.0', 'dev');
INSERT INTO installed_packages (name, manager, version, label)
VALUES ('dust', 'snap', '3.0.0', 'dev');
INSERT INTO installed_packages (name, manager, version, label)
VALUES ('make', 'snap', '1.8.9', 'dev');
INSERT INTO installed_packages (name, manager, version, label)
VALUES ('done', 'apt-get', '2.0.0', 'php');
EOF
}