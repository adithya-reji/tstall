edit_package_label () {
    local package="$1"
    local label="$2"
    local result

    if [[ -z "$package" ]] || [[ -z "$label" ]]; then
        echo -e "\033[0;31mError: requires both <package> and <label>.\033[0m"
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
        echo -e "\033[0;32mLabel updated for $package to '$label'.\033[0m"
        return 0
    fi
}