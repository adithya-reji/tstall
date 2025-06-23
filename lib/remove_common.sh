get_remove_package_manager () {
    local package="$1"
    local pkg_manager=$(sqlite3 "$DB_FILE" "SELECT DISTINCT manager FROM installed_packages WHERE name='${package//\'/''}' LIMIT 1;")
    echo "$pkg_manager"
}

update_remove_to_db () {
    local pkg="$1"
    sqlite3 "$DB_FILE" <<EOF
DELETE FROM installed_packages WHERE name='${pkg//\'/''}';
EOF
}

is_installed_with_tstall () {
    local pkg="$1"
    local count=$(sqlite3 "$DB_FILE" "SELECT COUNT(*) FROM installed_packages WHERE name='${pkg//\'/''}';")

    if (( count == 0 )); then
        return 1
    else
        return 0
    fi
}

try_remove_package () {
    local pkg_manager="$1"
    local pkg="$2"
    local success=false
    local log_file="$LOG_DIR/remove_${pkg}.log"
    local show_log

    case $pkg_manager in 
        "apt")
            echo -e "Attempting removal of \033[1m$pkg\033[0m using \033[1mapt\033[0m"
            if sudo apt purge -y "$pkg" &>>"$log_file"; then
                success=true
            fi
            ;;
        "apt-get")
            echo -e "Attempting removal of \033[1m$pkg\033[0m using \033[1mapt-get\033[0m"
            if sudo apt-get remove -y "$pkg" &>>"$log_file"; then
                success=true
            fi
            ;;
        "dnf")
            echo -e "Attempting removal of \033[1m$pkg\033[0m using \033[1mdnf\033[0m"
            if sudo dnf remove -y "$pkg" &>>"$log_file"; then
                success=true
            fi
            ;;
        "yum")
            echo -e "Attempting removal of \033[1m$pkg\033[0m using \033[1myum\033[0m"
            if sudo yum remove -y "$pkg" &>>"$log_file"; then
                success=true
            fi
            ;;
        "pacman")
            echo -e "Attempting removal of \033[1m$pkg\033[0m using \033[1mpacman\033[0m"
            if sudo pacman -Rns --noconfirm "$pkg" &>>"$log_file"; then
                success=true
            fi
            ;;
        "zypper")
            if sudo zypper remove -y "$pkg" &>>"$log_file"; then
                success=true
            fi
            ;;
        *)
            echo -e "\033[0;31mError: Unsupported package manager $pkg_manager\033[0m"
            return 1
            ;;
    esac

    if $success; then
        echo -e "\033[0;32mSuccessfully removed $pkg.\033[0m"
        update_remove_to_db "$pkg"

        # Show log
        read -p "Do you want to view the log? [y/N]: " show_log
        show_log="${show_log,,}"

        if [[ -z "$show_log" ]] || [[ "$show_log" != "y" ]]; then
            show_log="n"
        fi
        
        if [[ "$show_log" == "y" ]] ; then
            less "$log_file" || cat "$log_file"
        fi
        rm -f "$log_file"

        return 0
    else
        echo -e "\033[0;31mError: Failed to remove $pkg using $pkg_manager.\033[0m" >&2
        less "$log_file" || cat "$log_file"
        rm -f "$log_file"
        return 1
    fi
}