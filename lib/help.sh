help () {
    cat << EOF
$PROGRAM_NAME - Helps you manage packages using labels. Installed packages 
can be labeled to group them together, enabling management of packages and 
performing operations such as removal based on labels.


Usage: $PROGRAM_NAME [options] <command>

Basic commands:
  install                 install packages.
  remove                  remove packages.
  remove-label            remove all packages with the label.
  list                    list all installed packages.
  list-labels             list all labels.
  search                  search an installed package.
  search-label           search all packages with the label.
  edit-package-label      edit an installed package label.
  rename-label            rename a label.


Options:
  -h, --help, help        show this help message.
  -v, --version           show version info.

Examples:
  $PROGRAM_NAME install <package>...
  $PROGRAM_NAME edit-package-label <package> <label>

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
    edit-package-label)
      help_edit_package_label
      ;;
    rename-label)
      help_edit_label
      ;;
    *)
      echo "\033[0;31mError: unknown command, type '$PROGRAM_NAME help' for help.\033[0m"

  esac
}

help_install_package () {
  cat << EOF
Usage: 
  $PROGRAM_NAME install <package>...
  $PROGRAM_NAME install <package manager> <package>...

The install command is used to install <package> from the available package manager on the system.
EOF
}

help_remove_package () {
 cat << EOF
Usage: 
  $PROGRAM_NAME remove <package>...

The remove command helps to remove/uninstall <package> installed with tstall.
EOF
}

help_remove_label () {
  cat << EOF
Usage: 
  $PROGRAM_NAME remove-label <label>

The remove-label command helps to remove/uninstall all the packages with the specified <label>.
EOF
}

help_list () {
  cat << EOF
Usage: 
  $PROGRAM_NAME list

The list command lists all the installed packages data with tstall.
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

The search command is used to search for the <package>.
EOF
}

help_search_label () {
  cat << EOF
Usage: 
  $PROGRAM_NAME search-label <label>

The search-label command helps to find all the packages that has the specified <label>.
EOF
}

help_edit_package_label () {
  cat << EOF
Usage:
  $PROGRAM_NAME edit-package-label <package> <label>

The edit-package-label command is used to edit the label of the specified <package> and replaces it with the <label>.
EOF
}

help_rename_label () {
  cat << EOF
Usage:
  $PROGRAM_NAME rename-label <label> <new label>

The rename-label command is used to rename the specified <label> with the <new label>.
EOF
}