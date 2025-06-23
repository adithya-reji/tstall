rename_label () {
    local label="$1"
    local new_label="$2"
    local confirm="y"
    local result

    if sqlite3 "$DB_FILE" "SELECT 1 FROM installed_packages WHERE label='${new_label//\'/''}' LIMIT 1;" | grep -q 1; then
        echo -e "\033[0;33mWarning: Label '\033[1m$new_label\033[0m\033[0;33m' already exist.\033[0m"
        while true; do 
            read -p "Are you sure you want to rename the label '$label' to '$new_label'? [y/n]: " confirm
            confirm=${confirm,,}

            if [[ -z "$confirm" || ( "$confirm" != "y" && "$confirm" != "n" ) ]]; then
                echo -e "\033[0;31mError: Invalid input. Please enter 'y' or 'n'.\033[0m"
            else
                break
            fi
        done
    fi

    if [[ "$confirm" == "y" ]]; then
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
            echo -e "No matching label found or the label is already set to '\033[1m$new_label\033[0m'."
            return 1
        else
            echo -e "Label '\033[1m$label\033[0m' updated to '\033[1m$new_label\033[0m'."
            return 0
        fi
    elif [[ "$confirm" == "n" ]]; then
        echo -e "\033[1mAborted label renaming.\033[0m"
        return
    fi

}