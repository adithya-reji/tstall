search_label () {
    local search_label="$1"
    local search_result

    search_result=$(sqlite3 "$DB_FILE" "SELECT COUNT(*) FROM installed_packages WHERE label='${search_label//\'/''}';")

    if (( search_result == 0 )); then
        echo "No package found with label: $search_label"
    else
        {
    echo -e "\033[1;33mControls:\033[0m"
    echo -e "\e[7m↑ / ↓ : Scroll up/down | ← / → : Scroll left/right | Space : Next page | q : Quit view\e[0m"
    echo
    
    sqlite3 "$DB_FILE" <<EOF
.headers on
.mode column
.width 15 30 15 15 40
SELECT * FROM installed_packages WHERE label='${search_label//\'/''}';
EOF
} | LESS='-SR' less
    fi

}