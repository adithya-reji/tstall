rename_label () {
    local label="$1"
    local new_label="$2"
    local result

    if [[ -z "$label" ]] || [[ -z "$new_label" ]]; then
        echo "Error: requires both <label> and <new label>."
    fi

    result=$(sqlite3 "$DB_FILE" <<EOF
BEGIN;
UPDATE installed_packages
SET label='${new_label//\'/''}'
WHERE label='${label//\'/''}';
SELECT changes();
COMMIT;
EOF
    )

    if [[ "$result" -eq 0 ]]; then
        echo "No matching label found or the label is already set to '$new_label'."
        return 1
    else
        echo "Label '$label' updated to '$new_label'."
        return 0
    fi

}