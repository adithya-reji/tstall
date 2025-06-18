remove_package () {
    local packages=("$@")
    local pkg_manager
    local confirm
    local failed_pkgs=()

    echo "The following packages will be removed: "
    echo -e "\033[1m${packages[@]}\033[0m"
    read -p "Are you sure you want to remove these packages? [y/N]: " confirm
    confirm=${confirm,,}
    if [[ -z "$confirm" ]] || [[ "$confirm" != "y" ]]; then
        confirm="n"
    fi

    if [[ "$confirm" == "y" ]]; then
        for pkg in "${packages[@]}"; do
            pkg_manager=$(get_remove_package_manager "$pkg")
            if ! try_remove_package "$pkg_manager" "$pkg"; then
                failed_pkgs+=("$pkg")
            fi
        done
    elif [[ "$confirm" == "n" ]]; then
        echo -e "\033[1mAborted package removal.\033[0m"
    fi

    if [[ -z "${failed_pkgs[@]}" ]]; then
        echo -e "\033[0;31mFailed to remove:\033[1m ${failed_pkgs[*]} \033[0m"
    fi
}