#!/usr/bin/env bash

set -e

mkdir -p "$HOME/.config/tstall" "$HOME/.local/share/tstall"
cp config/config.conf "$HOME/.config/tstall"
cp schema/init.sql "$HOME/.local/share/tstall"

if command -v sqlite3 >/dev/null; then
    sqlite3 "$HOME/.local/share/tstall/tstall.db" < schema/init.sql
else
    echo "sqlite3 not found. Please install it."
    exit 1
fi

sudo mkdir -p /usr/local/share/tstall/lib
sudo cp -r lib/* /usr/local/share/tstall/lib/

sudo install -m 755 bin/tstall /usr/local/bin/tstall
sudo install -m 755 uninstall.sh /usr/local/bin/tstall-uninstall
echo "tstall installed successfully."
