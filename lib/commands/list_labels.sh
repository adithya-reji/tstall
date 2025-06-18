list_labels () {
    local labels

    labels=$(sqlite3 "$DB_FILE" "SELECT DISTINCT label FROM installed_packages;")

    if [[ -z "$labels" ]]; then
        echo "No labels found."
    else
        echo "$labels" | column
    fi
}