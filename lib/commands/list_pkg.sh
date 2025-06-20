list_installed_packages() {
    local count

    count=$(sqlite3 "$DB_FILE" "SELECT COUNT(*) FROM installed_packages;")

    if (( count == 0 )); then
        echo "No data found."
    else
    {
        echo -e "\033[1;33mControls:\033[0m"
        echo -e "\e[7m↑ / ↓ : Scroll up/down | ← / → : Scroll left/right | Space : Next page | q : Quit view\e[0m"
        echo
        
        sqlite3 "$DB_FILE" <<EOF
.headers on
.mode column
.width 15 30 15 15 40
SELECT * FROM installed_packages
ORDER BY datetime(installed_at) DESC;
EOF
} | LESS='-SR' less
    fi
}