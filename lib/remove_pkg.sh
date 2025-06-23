remove_package () {
    local packages=("$@")
    local pkg_to_remove=()
    local pkg_manager
    local confirm
    local failed_pkgs=()

    for pkg in "${packages[@]}"; do
        if is_package_installed "$pkg"; then
            if is_installed_with_tstall "$pkg"; then
                pkg_to_remove+=("$pkg")
            else
                echo -e "\033[0;36mThe package \033[1m$pkg\033[0m \033[0;36mwas not installed using tstall. Try removing manually.\033[0m"
                return 1
            fi
        else
            echo -e "\033[0;31mError: \033[1m$pkg\033[0m \033[0;31mnot found.\033[0m"
            return 1
        fi
    done

    if (( ${#pkg_to_remove[@]} == 1 )); then
        echo -e "The package \033[1m${pkg_to_remove[@]}\033[0m will be removed."
    elif (( ${#pkg_to_remove[@]} > 1 )); then
        echo "The following packages will be removed: "
        for pkg in "${pkg_to_remove[@]}"; do
            echo "  - $pkg"
        done
    fi

    read -p "Are you sure you want to proceed? [y/N]: " confirm
    confirm=${confirm,,}
    if [[ -z "$confirm" ]] || [[ "$confirm" != "y" ]]; then
        confirm="n"
    fi

    if [[ "$confirm" == "y" ]]; then
        for pkg in "${pkg_to_remove[@]}"; do
            pkg_manager=$(get_remove_package_manager "$pkg")
            if [[ -z "$pkg_manager" ]]; then
                echo -e "\033[0;31mError: No package manager found for \033[1m$pkg\033[0m."
                continue
            fi
            if ! try_remove_package "$pkg_manager" "$pkg"; then
                failed_pkgs+=("$pkg")
            fi
        done
    elif [[ "$confirm" == "n" ]]; then
        echo -e "\033[1mAborted package removal.\033[0m"
        return 0
    fi

    if (( ${#failed_pkgs[@]} > 1 )); then
        echo -e "\033[0;31mError: Failed to remove: \033[1m ${failed_pkgs[*]} \033[0m" >&2
    fi
}