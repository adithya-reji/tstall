#!/usr/bin/env bash

managers=("apt" "apt-get" "dnf" "yum" "pacman" "zypper")

detect_available_pm () {
    local found=()
    for manager in "${managers[@]}"; do
        if command -v "$manager" &>/dev/null; then
            found+=("$manager")
        fi
    done
    echo "${found[@]}"
}

available_managers=($(detect_available_pm))

get_pkg_install_labels () {
    sqlite3 "$DB_FILE" "SELECT DISTINCT label FROM installed_packages WHERE label IS NOT NULL and label != '';"
}

select_pkg_install_label () {
    local labels=("$@")
    labels+=("$(tput bold)$(tput setaf 6)Add new label$(tput sgr0)")

    PS3="Choose an option: "
    select label in "${labels[@]}"; do
        if [[ -n "$label" ]]; then
            if [[ "$label" == "$(tput bold)$(tput setaf 6)Add new label$(tput sgr0)" ]]; then
                echo "__custom__"
            else
                echo "$label"
            fi
            return 0
        else
            echo -e "\033[0;31mError: Invalid choice.\033[0m" >&2
        fi 
    done
}

get_pkg_install_version () {
    local pkg="$1"
    dpkg -s "$pkg" 2>/dev/null | grep '^Version:' | awk '{print $2}'
}

update_install_to_db () {
    local manager="$1"
    local pkg="$2"
    local version="$3"
    local label="$4"

    sqlite3 "$DB_FILE" <<EOF
INSERT INTO installed_packages (name, manager, version, label)
VALUES ('${pkg//\'/\'\'}', '${manager//\'/\'\'}', '${version//\'/\'\'}', '${label//\'/\'\'}');
EOF
}

valid_label () {
    local label

    while true; do
        read -p "Enter new label (letters and underscores only, no spaces): " label
        if [[ "$label" =~ ^[a-zA-Z_]+$ ]]; then
            echo "$label"
            break
        else
            echo -e "\033[0;31mError: Invalid label. Please use only letters and underscores, with no spaces.\033[0m" >&2
        fi
    done
}

try_install_package () {
    local pkg_manager="$1"
    local pkg="$2"
    local success=false
    local -a existing_labels
    local selected_label
    local pkg_version
    local pkg_label
    local log_file="$LOG_DIR/install_${pkg}.log"
    local show_log

    case $pkg_manager in
        "apt")
            echo -e "Attempting installation of \033[1m$pkg\033[0m using \033[1mapt\033[0m"
            if sudo sudo apt update &>>"$log_file" && sudo apt install -y "$pkg" &>>"$log_file"; then
                success=true
            fi
            ;;
        "apt-get")
            echo -e "Attempting installation of \033[1m$pkg\033[0m using \033[1mapt-get\033[0m"
            if sudo apt-get update &>>"$log_file" && sudo apt-get install -y "$pkg" &>>"$log_file"; then
                success=true
            fi
            ;;
        "dnf")
            echo -e "Attempting installation of \033[1m$pkg\033[0m using \033[1mdnf\033[0m"
            if sudo dnf install -y "$pkg" &>>"$log_file"; then
                success=true
            fi
            ;;
        "yum")
            echo -e "Attempting installation of \033[1m$pkg\033[0m using \033[1myum\033[0m"
            if sudo yum install -y "$pkg" &>>"$log_file"; then
                success=true
            fi
            ;;
        "pacman")
            echo -e "Attempting installation of \033[1m$pkg\033[0m using \033[1mpacman\033[0m"
            if sudo pacman -Sy --noconfirm "$pkg" &>>"$log_file"; then
                success=true
            fi
            ;;
        "zypper")
            echo -e "Attempting installation of \033[1m$pkg\033[0m using \033[1mzypper\033[0m"
            if sudo zypper install -y "$pkg" &>>"$log_file"; then
                success=true
            fi
            ;;
        *)
            echo -e "\033[0;31mError: Unsupported package manager $pkg_manager\033[0m"
            return 1
            ;;
    esac

    if $success; then
        echo -e "\033[0;32mSuccessfully installed $pkg using $pkg_manager\033[0m"

        # Update the install to the db
        read -p "Do you want to add a label? [Y/n]: " pkg_label
        pkg_label="${pkg_label,,}"

        if [[ -z "$pkg_label" ]] || [[ "$pkg_label" != "n" ]] ; then
            pkg_label="y"
        fi

        if [[ "$pkg_label" == "y" ]]; then
            readarray -t existing_labels < <(get_pkg_install_labels)

            if (( ${#existing_labels[@]} == 0 )); then
                selected_label=$(valid_label)
            else
                selected_label=$(select_pkg_install_label "${existing_labels[@]}")
                if [[ "$selected_label" == "__custom__" ]]; then
                    selected_label=$(valid_label)
                fi
            fi
        fi

        pkg_version=$(get_pkg_install_version "$pkg")
        update_install_to_db "$pkg_manager" "$pkg" "$pkg_version" "$selected_label"

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
        echo -e "\033[0;31mError: Failed to install \033[1m$pkg\033[0m using \033[1m$pkg_manager\033[0m" >&2
        less "$log_file" || cat "$log_file"
        rm -f "$log_file"
        return 1
    fi
}

get_multi_pkg_install_managers () {
    local packages=("$@")
    local -A pkg_managers
    local selected_manager
    local failed_pkgs=()

    for pkg in "${packages[@]}"; do
        echo -e "Select a package manager to install \033[1m$pkg\033[0m: " >&2
        selected_manager=$(select_install_package_manager)
        if [[ -n "$selected_manager" ]]; then
            pkg_managers["$pkg"]="$selected_manager"
        else
            echo -e "\033[0;31mError: Invalid package manager.\033[0m" >&2
        fi
    done

    for pkg in "${packages[@]}"; do
        if ! try_install_package "${pkg_managers[$pkg]}" "$pkg"; then
            failed_pkgs+=("$pkg")
        fi
    done

    printf '%s\n' "${failed_pkgs[@]}"
}

select_install_package_manager () {
    if [[ -n "$1" ]]; then
        for manager in "${available_managers[@]}"; do
            if [[ "$manager" == "$1" ]]; then
                echo "$1"
                return 0
            fi
        done
        echo ""
        return
    else
        if (( ${#available_managers[@]} == 1 )); then
            echo "${available_managers[0]}"
            return 0
        elif (( ${#available_managers[@]} > 1 )); then
            PS3="Choose a package manager: "
            select pkg_manager in "${available_managers[@]}"; do
                if [[ -n "$pkg_manager" ]]; then
                    echo "$pkg_manager"
                    return 0
                else
                    echo -e "\033[0;31mError: Invalid choice. Please choose a valid package manager.\033[0m" >&2
                fi
            done
        fi
    fi
}

is_package_installed () {
    local pkg="$1"
    dpkg -s "$pkg" &> /dev/null && return 0
    snap list | grep -q "^$pkg" && return 0
    flatpak list | grep -q "$pkg" && return 0
    return 1
}

install_package () {
    local user_choice_pm=false
    local packages=()
    local pkg_to_install=()
    local selected_manager
    local -A pkg_manager_map
    local failed_pkgs=()

    if (( ${#available_managers[@]} == 0 )); then
        echo -e "\033[0;31mError: No package manager available.\033[0m" >&2
        return 1
    fi

    # Checks if the first argument is a package manager
    selected_manager=$(select_install_package_manager "$1")

    # Checks if user choice exist
    if [[ -n "$selected_manager" ]]; then
        user_choice_pm=true
        shift
    fi

    packages=("$@")

    # Checks if the package is already installed
    for pkg in "${packages[@]}"; do
        if is_package_installed "$pkg"; then
            echo -e "\033[1m$pkg\033[0m already installed."
            return 1
        else
            pkg_to_install+=("$pkg")
        fi
    done

    # Checks if user choice package manager exist
    if $user_choice_pm; then
        for pkg in "${pkg_to_install[@]}"; do
            if ! try_install_package "$selected_manager" "$pkg"; then
                failed_pkgs+=("$pkg")
            fi
        done
    else
        # Checks if package to install is greater than 1
        if (( ${#pkg_to_install[@]} > 1 )); then
            PS3="Choose an option: "
            select option in "Install from a single package manager." "Install from multiple package managers."
            do
                case $option in
                    "Install from a single package manager.")
                        echo -e "Choose a package manager to install \033[1m${pkg_to_install[@]}\033[0m: "
                        selected_manager=$(select_install_package_manager)
                        for pkg in "${pkg_to_install[@]}"; do
                            if ! try_install_package "$selected_manager" "$pkg"; then
                                failed_pkgs+=("$pkg")
                            fi
                        done
                        break
                        ;;
                    "Install from multiple package managers.")
                        for pkg in "${pkg_to_install[@]}"; do
                            echo -e "Select a package manager to install \033[1m$pkg\033[0m: "
                            selected_manager=$(select_install_package_manager)
                            if [[ -n "$selected_manager" ]]; then
                                pkg_manager_map["$pkg"]="$selected_manager"
                            else
                                echo -e "\033[0;31mError: Invalid package manager.\033[0m"
                            fi
                        done

                        for pkg in "${pkg_to_install[@]}"; do
                            if ! try_install_package "${pkg_manager_map[$pkg]}" "$pkg"; then
                                failed_pkgs+=("$pkg")
                            fi
                        done
                        break
                        ;;
                    *)
                        echo -e "\033[0;31mError: Invalid choice. Please choose an installation method.\033[0m" >&2
                        break
                        ;;
                esac
            done
        elif (( ${#pkg_to_install[@]} == 1 )); then
            echo -e "Select a package manager to install \033[1m${pkg_to_install[@]}\033[0m:"
            selected_manager=$(select_install_package_manager)
            if [[ -n "$selected_manager" ]]; then
                if ! try_install_package "$selected_manager" "${pkg_to_install[0]}"; then
                    failed_pkgs+=("${pkg_to_install[0]}")
                fi
            else
                echo -e "\033[0;31mError: Invalid package manager.\033[0m" >&2
            fi
        fi
    fi

    if (( ${#pkg_to_install[@]} > 1 )); then
        if (( ${#failed_pkgs[@]} > 0 )); then
            echo -e "\033[0;31mError: Failed to install:\033[1m ${failed_pkgs[*]} \033[0m" >&2
        fi
    fi
}