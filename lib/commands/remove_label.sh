get_remove_label_packages () {
    local label="$1"
    local packages=($(sqlite3 "$DB_FILE" "SELECT name FROM installed_packages WHERE label='${label//\'/\'\'}';"))
    echo "${packages[@]}"
}

remove_label () {
    local label="$1"
    local packages=()
    local package_manager
    local confirm
    local failed_pkgs=()

    packages=($(get_remove_label_packages "$label"))
    echo "The following packages will be removed: "
    echo -e "\033[1m${packages[@]}\033[0m"
    read -p "Are you sure you want to proceed? [y/N]: " confirm
    confirm=${confirm,,}

    if [[ -z "$confirm" ]] || [[ $confirm != "y" ]]; then
        confirm="n"
    fi

    if [[ "$confirm" == "y" ]]; then
        for pkg in "${packages[@]}"; do
            package_manager=$(get_remove_package_manager "$pkg")
            if ! try_remove_package "$package_manager" "$pkg"; then
                failed_pkgs+=("$pkg")
            fi
        done
    else
        echo -e "\033[1mAborted label removal.\033[0m"
        return 0
    fi

    if (( ${#failed_pkgs[@]} > 1 )); then
        echo -e "\033[0;31mFailed to remove: \033[1m ${failed_pkgs[*]} \033[0m" >&2
    fi
}