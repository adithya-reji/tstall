help () {
    local PROGRAM_NAME="tstall"
    cat << EOF
$PROGRAM_NAME - [Short description of your tool]

Usage: $PROGRAM_NAME [options] <command>

Basic commands:
  install           install packages.
  remove            remove packages.
  list              list all installed packages.
  list-labels       list all labels.
  search            search installed package.
  search-labels     search labels.
  edit              Edit an installed package data.
  edit-label        Edit a label.


Options:
  -h, --help, help  Show this help message.
  -v, --version     Show version info.

Examples:
  $PROGRAM_NAME install [package...]
  $PROGRAM_NAME list

For more information about a command, run '$PROGRAM_NAME help <command>'.
EOF
}

help_command () {
  local command="$1"
  case "$command" in
    install)
      help_install_package
      ;;
    remove)
      help_remove_package
      ;;
    remove-label)
      help_remove_label
      ;;
    list)
      help_list
      ;;
    list-labels)
      help_list_labels
      ;;
    search)
      help_search_package
      ;;
    search-label)
      help_search_label
      ;;
    *)
      echo "Error: unknown command, type '$PROGRAM_NAME help' for help."

  esac
}

help_install_package () {
  cat << EOF
Usage: 
  $PROGRAM_NAME install <package>...
  $PROGRAM_NAME install <package manager> <package>...

The install command is used to install packages from the available package manager on the system.
EOF
}

help_remove_package () {
 cat << EOF
Usage: 
  $PROGRAM_NAME remove <package>...

The remove command helps to remove/uninstall packages installed with tstall.
EOF
}

help_remove_label () {
  cat << EOF
Usage: 
  $PROGRAM_NAME remove-label <label>...

The remove-label command helps to remove/uninstall all the packages with the specified labels.
EOF
}

help_list () {
  cat << EOF
Usage: 
  $PROGRAM_NAME list

The list command lists all the installed packages with tstall.
EOF
}

help_list_labels () {
  cat << EOF
Usage: 
  $PROGRAM_NAME list-labels

The list-labels command lists all the existing labels.
EOF
}

help_search_package () {
  cat << EOF
Usage: 
  $PROGRAM_NAME search <package>

The search command is used to search for a package.
EOF
}

help_search_label () {
  cat << EOF
Usage: 
  $PROGRAM_NAME search-label <label>

The search-label command helps to find all the packages that has the specified label.
EOF
}