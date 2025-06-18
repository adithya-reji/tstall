search_pkg () {
    local search_pkg="$1"
    local search_result

    search_result=$(sqlite3 "$DB_FILE" "SELECT COUNT(*) FROM installed_packages WHERE name='${search_pkg//\'/''}';")

    if (( search_result == 0 )); then
        echo "No package found with name: $search_pkg"
    else
        sqlite3 "$DB_FILE" <<EOF
.headers on
.mode column
.width 15 30 15 15 40
SELECT * FROM installed_packages WHERE name='${search_pkg//\'/''}';
EOF
    fi
}