get_remove_label_packages () {
    local label="$1"
    sqlite3 "$DB_FILE" "SELECT name FROM installed_packages WHERE label='${label//\'/\'\'}';"
}

remove_label () {
    local label="$1"
    local packages=()
    local pkg_to_remove=()
    local package_manager
    local confirm
    local failed_pkgs=()

    # packages=($(get_remove_label_packages "$label"))
    readarray -t packages < <(get_remove_label_packages "$label")

    for pkg in "${packages[@]}"; do
        if is_package_installed "$pkg"; then
            if is_installed_with_tstall "$pkg"; then
                pkg_to_remove+=("$pkg")
            else
                echo -e "The package \033[1m$pkg\033[0m was not installed using tstall. Try removing manually."
            fi
        else
            echo -e "\033[1m$pkg\033[0m not found."
        fi
    done

    echo "The following packages will be removed: "
    echo -e "\033[1m${pkg_to_remove[@]}\033[0m"
    read -p "Are you sure you want to proceed? [y/N]: " confirm
    confirm=${confirm,,}

    if [[ -z "$confirm" ]] || [[ $confirm != "y" ]]; then
        confirm="n"
    fi

    if [[ "$confirm" == "y" ]]; then
        for pkg in "${pkg_to_remove[@]}"; do
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