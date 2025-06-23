#!/usr/bin/env bash

read -p "This will uninstall tstall. Continue? [y/N]: " confirm
[[ "$confirm" =~ ^[Yy]$ ]] || exit 0

sudo rm -f /usr/local/bin/tstall
rm -rf "$HOME/.config/tstall" "$HOME/.local/share/tstall"

echo "tstall has been removed."