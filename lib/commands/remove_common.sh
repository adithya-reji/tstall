get_remove_package_manager () {
    local package="$1"
    local pkg_manager=$(sqlite3 "$DB_FILE" "SELECT manager FROM installed_packages WHERE name='${package//\'/''}';")
    echo "$pkg_manager"
}

update_remove_to_db () {
    local pkg="$1"
    sqlite3 "$DB_FILE" <<EOF
DELETE FROM installed_packages WHERE name='${pkg//\'/''}';
EOF
}

try_remove_package () {
    local pkg_manager="$1"
    local pkg="$2"
    local success=false

    case $pkg_manager in 
        "apt")
            echo "Attempting removal using apt"
            success=true
            ;;
        "apt-get")
            echo "Attempting removal using apt-get"
            success=true
            ;;
        "dnf")
            echo "Attempting removal using dnf"
            success=true
            ;;
        "yum")
            echo "Attempting removal using yum"
            success=true
            ;;
        "pacman")
            echo "Attempting removal using pacman"
            success=true
            ;;
        "opkg")
            echo "Attempting removal using opkg"
            success=true
            ;;
        "snap")
            echo "Attempting removal using snap"
            success=true
            ;;
    esac

    if $success; then
        echo -e "\033[0;32mSuccessfully removed $pkg.\033[0m"
        update_remove_to_db "$pkg"
        return 0
    else
        echo -e "\033[0;31mFailed to remove $pkg using $pkg_manager.\033[0m"
        return 1
    fi
}