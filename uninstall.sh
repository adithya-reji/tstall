#!/usr/bin/env bash

read -p "This will uninstall tstall. Continue? [y/N]: " confirm
[[ "$confirm" =~ ^[Yy]$ ]] || exit 0

echo "Uninstalling tstall..."

sudo rm -f /usr/local/bin/tstall
rm -rf "$HOME/.config/tstall" "$HOME/.local/share/tstall"

if [[ "$0" == "/usr/local/bin/tstall-uninstall" ]]; then
    echo "Removing the uninstaller itself..."
    sudo rm -f /usr/local/bin/tstall-uninstall
fi

echo "tstall has been removed."