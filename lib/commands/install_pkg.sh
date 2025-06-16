#!/bin/bash

managers=("apt" "apt-get" "dnf" "yum" "pacman" "opkg" "snap")

detect_available_pm() {
    local found=()
    for manager in "${managers[@]}"; do
        if command -v "$manager" &>/dev/null; then
            found+=("$manager")
        fi
    done
    echo "${found[@]}"
}

available_managers=($(detect_available_pm))

apt_install() {
    local pkg="$1"
    if sudo apt-get install -y "$pkg" > >(tee /tmp/install_output) 2> >(tee /tmp/install_error >&2); then
        echo "Installation succeeded"
        # Save to SQLite
    else
        echo "Installation failed"
        # Skip or log failure
    fi
}

get_labels() {
    local -a labels

    mapfile -t labels < <(sqlite3 "$DB_FILE" "SELECT DISTINCT label FROM installed_packages WHERE label IS NOT NULL;")
    echo "${labels[@]}"
}

select_label() {
    local labels=("$@")
    # local new_label
    select label in "${labels[@]}" "$(tput bold)$(tput setaf 6)Add new label$(tput sgr0)"; do
        if [[ -n "$label" ]]; then
            echo "$label"
            return
        else
            echo ""
        fi 
    done
}

get_version() {
    local pkg="$1"
    dpkg -s "$pkg" 2>/dev/null | grep '^Version:' | awk '{print $2}'
}

log_to_sqlite() {
    local pkg="$1"
    local manager="$2"
    local version="$3"
    local label="$4"

    sqlite3 "$DB_FILE" <<EOF
INSERT INTO installed_packages (name, manager, version, label)
VALUES ('$pkg', '$manager', '$version', '$label');
EOF
}

try_install() {
    local pkg="$1"
    local pkg_manager="$2"
    local success=false
    local version
    local label="n"
    local log_file="/tmp/${pkg}_${pkg_manager}.log"

    case $pkg_manager in
        "apt")
            # echo -e "\033[1mAttempting installation of $pkg using apt\033[0m"
            # if sudo apt-get update && sudo apt-get install -y "$pkg" > >(tee "$log_file") 2> >(tee -a "$log_file" >&2); then
            #     success=true
            # fi
            success=true
            ;;
        "apt-get")
            echo -e "\033[1mAttempting installation of $pkg using apt-get\033[0m"
            ;;
        "dnf")
            echo -e "\033[1mAttempting installation of $pkg using dnf\033[0m"
            ;;
        "yum")
            echo -e "\033[1mAttempting installation of $pkg using yum\033[0m"
            ;;
        "pacman")
            echo -e "\033[1mAttempting installation of $pkg using pacman\033[0m"
            ;;
        "opkg")
            echo -e "\033[1mAttempting installation of $pkg using opkg\033[0m"
            ;;
        "snap")
            echo -e "\033[1mAttempting installation of $pkg using snap\033[0m"
            if sudo snap install "$pkg" > >(tee "$log_file") 2> >(tee -a "$log_file" >&2); then
                success=true
            fi
            ;;
    esac

    if $success; then
        echo -e "\033[0;32mSuccessfully installed $pkg using $pkg_manager\033[0m"
        read -p "Do you want to add a label? [y/N] " label
        label="${label,,}"
        if [[ -z "$label" ]]; then
            label="n"
        fi
        if [[ "$label" == "y" ]]; then
            local existing_labels=($(get_labels))
            local selected_label=$(select_label "${existing_labels[@]}")
            if [[ "$selected_label" == "$(tput bold)$(tput setaf 6)Add new label$(tput sgr0)" ]]; then
                read -p "Enter new label: " selected_label
            fi
        fi
        version=$(get_version "$pkg")
        log_to_sqlite "$pkg" "$pkg_manager" "$version" "$selected_label"
        return 0
    else
        echo "Failed to install $pkg using $pkg_manager"
        return 1
    fi
}

get_multi_pkg_managers() {
    local -A pkg_managers
    local packages=("$@")
    local selected_manager

    for pkg in "${packages[@]}"; do
        echo
        echo -e "Select a package manager to install \033[1m$pkg\033[0m: "
        selected_manager=$(select_package_manager)
        if [[ -n "$selected_manager" ]]; then
            pkg_managers["$pkg"]="$selected_manager"
        else
            echo "Invalid package manager."
        fi
    done
    for pkg in "${packages[@]}"; do
        echo
        try_install "$pkg" "${pkg_managers[$pkg]}"
    done
}

select_package_manager() {
    if [[ -n "$1" ]]; then
        for manager in "${available_managers[@]}"; do
            if [[ "$manager" == "$1" ]]; then
                echo "$1"
                return 0
            fi
        done
        echo ""
        return 1
    else
        if [[ "${#available_managers[@]}" -eq 1 ]]; then
            echo "${available_managers[0]}"
            return 0
        elif [[ "${#available_managers[@]}" -gt 1 ]]; then
            select pkg_manager in "${available_managers[@]}"; do
                if [[ -n "$pkg_manager" ]]; then
                    echo "$pkg_manager"
                    return 0
                else
                    echo "Invalid choice. Please try again." >&2
                fi
            done
        fi
    fi
}

is_installed() {
    local pkg="$1"
    dpkg -s "$pkg" &> /dev/null && return 0
    snap list | grep -q "^$pkg" && return 0
    flatpak list | grep -q "$pkg" && return 0
    return 1
}

install_package() {
    local user_choice_pm=false
    local packages=()
    local pkg_to_install=()
    local selected_manager

    # Checks if the first argument is a package manager
    selected_manager=$(select_package_manager "$1")

    # Checks if user choice exist
    if [[ -n "$selected_manager" ]]; then
        user_choice_pm=true
        shift
    fi

    packages=("$@")

    # Checks if the package is already installed
    for pkg in "${packages[@]}"; do
        if is_installed "$pkg"; then
            echo -e "\033[1m$pkg\033[0m already installed."
        else
            pkg_to_install+=("$pkg")
        fi
    done

    if $user_choice_pm; then
        for pkg in "${pkg_to_install[@]}"; do
            try_install "$pkg" "$selected_manager"
        done
    else
        if [[ "${#pkg_to_install[@]}" -gt 1 ]]; then
            # Selects package manager for multiple pkg installation
            select option in "Install from a single package manager." "Install from multiple package managers."
            do
                case $option in
                    "Install from a single package manager.")
                        echo -e "\nSelect a package manager to install \033[1m${pkg_to_install[@]}\033[0m: "
                        selected_manager=$(select_package_manager)
                        for pkg in "${pkg_to_install[@]}"; do
                            echo
                            try_install "$pkg" "$selected_manager"
                        done
                        break
                        ;;
                    "Install from multiple package managers.")
                        get_multi_pkg_managers "${pkg_to_install[@]}"
                        break
                        ;;
                esac
            done
        elif [[ "${#pkg_to_install[@]}" -eq 1 ]]; then
            echo -e "Select a package manager to install \033[1m${pkg_to_install[@]}\033[0m:"
            selected_manager=$(select_package_manager)
            if [[ -n "$selected_manager" ]]; then
                echo
                try_install "${pkg_to_install[0]}" "$selected_manager"
            else
                echo "Invalid package manager."
            fi
        fi
    fi
}