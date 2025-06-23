#!/usr/bin/env bash

source "$SCRIPT_DIR/install_pkg.sh"
# source lib/commands/install_pkg.sh
source "$SCRIPT_DIR/remove_pkg.sh"
# source lib/commands/remove_pkg.sh
source "$SCRIPT_DIR/remove_label.sh"
# source lib/commands/remove_label.sh
source "$SCRIPT_DIR/remove_common.sh"
# source lib/commands/remove_common.sh
source "$SCRIPT_DIR/list_pkg.sh"
# source lib/commands/list_pkg.sh
source "$SCRIPT_DIR/list_labels.sh"
# source lib/commands/list_labels.sh
source "$SCRIPT_DIR/search_pkg.sh"
# source lib/commands/search_pkg.sh
source "$SCRIPT_DIR/search_label.sh"
# source lib/commands/search_label.sh
source "$SCRIPT_DIR/edit_package_label.sh"
# source lib/commands/edit_package_label.sh
source "$SCRIPT_DIR/rename_label.sh"
# source lib/commands/rename_label.sh
source "$SCRIPT_DIR/help.sh"
# source lib/commands/help.sh

main() {
    local CMD="$1"
    shift
    case "$CMD" in
        install)
            if [[ -n "$@" ]]; then
                install_package "$@"
            else
                echo -e "\033[0;31mError: requires atleast one <package>, type '$PROGRAM_NAME help $CMD' for help.\033[0m"
            fi
            ;;
        remove)
            if [[ -n "$@" ]]; then
                remove_package "$@"
            else
                echo -e "\033[0;31mError: requires atleast one <package>, type '$PROGRAM_NAME help $CMD' for help.\033[0m"
            fi
            ;;
        remove-label)
            if [[ $# -eq 1 ]]; then
                remove_label "$1"
            elif [[ $# -gt 1 ]]; then
                echo -e "\033[0;31mError: too many arguments for command, type '$PROGRAM_NAME help $CMD' for help.\033[0m"
            else
                echo -e "\033[0;31mError: requires <label>, type '$PROGRAM_NAME help $CMD' for help.\033[0m"
            fi
            ;;
        list)
            if [[ -z "$@" ]]; then
                list_installed_packages
            else
                echo -e "\033[0;31mError: too many arguments for command, type '$PROGRAM_NAME help' for help.\033[0m"
            fi
            ;;
        list-labels)
            if [[ -z "$@" ]]; then
                list_labels
            else
                echo -e "\033[0;31mError: too many arguments for command, type '$PROGRAM_NAME help' for help.\033[0m"
            fi
            ;;
        search)
            if [[ $# -eq 1 ]]; then
                search_pkg "$1"
            elif [[ $# -gt 1 ]]; then
                echo -e "\033[0;31mError: too many arguments for command, type '$PROGRAM_NAME help $CMD' for help.\033[0m"
            else
                echo -e "\033[0;31mError: requires <package>, type '$PROGRAM_NAME help $CMD' for help.\033[0m"
            fi
            ;;
        search-label)
            if [[ $# -eq 1 ]]; then
                search_label "$1"
            elif [[ $# -gt 1 ]]; then
                echo -e "\033[0;31mError: too many arguments for command, type '$PROGRAM_NAME help $CMD' for help.\033[0m"
            else
                echo -e "\033[0;31mError: requires <label>, type '$PROGRAM_NAME help $CMD' for help.\033[0m" 
            fi
            ;;
        edit-package-label)
            if [[ $# -eq 2 ]]; then
                edit_package_label "$1" "$2"
            elif [[ $# -gt 2 ]]; then
                echo -e "\033[0;31mError: too many arguments for command, type '$PROGRAM_NAME help $CMD' for help.\033[0m"
            else
                echo -e "\033[0;31mError: requires <package> and <label>, type '$PROGRAM_NAME help $CMD' for help.\033[0m"
            fi
            ;;
        rename-label)
            if [[ $# -eq 2 ]]; then
                rename_label "$1" "$2"
            elif [[ $# -gt 2 ]]; then
                echo -e "\033[0;31mError: too many arguments for command, type '$PROGRAM_NAME help $CMD' for help.\033[0m"
            else
                echo -e "\033[0;31mError: requires <label> and <new label>, type '$PROGRAM_NAME help $CMD' for help.\033[0m"
            fi
            ;;
        -v|--version|version)
            if [[ -z "$@" ]]; then
                echo "$PROGRAM_NAME $PROGRAM_VERSION"
            else
                echo -e "\033[0;31mError: too many arguments for command, type '$PROGRAM_NAME help' for help.\033[0m"
            fi
            ;;
        -h|--help|help)
            if [[ "$#" -eq 0 ]]; then
                help
            elif [[ "$#" -eq 1 ]]; then
                help_command "$1"
            else
                echo -e "\033[0;31mError: too many arguments for command, type '$PROGRAM_NAME help' for help.\033[0m"
            fi
            ;;
        *)
            echo -e "\033[0;31mError: unknown command, type '$PROGRAM_NAME help' for help.\033[0m"
    esac
}