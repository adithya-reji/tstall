edit_package_label () {
    local package="$1"
    local label="$2"
    local result

    if [[ -z "$package" ]] || [[ -z "$label" ]]; then
        echo "Error: requires both <package> and <label>."
    fi

    result=$(sqlite3 "$DB_FILE" <<EOF
BEGIN;
UPDATE installed_packages
SET label='${label//\'/''}'
WHERE name='${package//\'/''}';
SELECT changes();
COMMIT;
EOF
)
    if [[ "$result" -eq 0 ]]; then
        echo "No matching package found or label is already set to '$label'."
        return 1
    else
        echo "Label updated for $package to '$label'."
        return 0
    fi
}