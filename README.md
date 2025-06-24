# tstall
A minimal Linux package manager warpper which helps to group and manage packages using labels. 

## Installation
The installation is simple. Run the following command in terminal.
```bash
git clone https://github.com/adithya-reji/tstall.git
cd tstall
chmod +x install.sh
./install.sh
```
## Uninstall
To uninstall simply run
```bash
./uninstall.sh
```
## Usage
To run the program, specify the command and the package or the label.
```bash
tstall <command> <package/label>
```

Basic commands
```bash
install
remove
remove-label
list
list-labels
search
search-label
edit-package-label
rename-label
help
version
```

* `install`:  Install package/packages on the system with the specified/available package manager and assign custom label to the installed package for easy grouping and management.
* `remove`: Remove package/packages from the system.
* `remove-label`: Remove all packages assigned with the label.
* `list`: List all the packages installed using tstall.
* `list-labels`: List all the existing labels.
* `search`: Search for a package installed using tstall.
* `search-label`: List all packages assigned with the specified label.
* `edit-package-label`: Edit the label of the specified package.
* `rename-label`: Rename the specified label.
* `help`: Show the help message.
* `version`: Show the version info.

## Requirements
* Bash 4+
* `sqlite3`
* A supported package manager: `apt`, `dnf`, `yum`, `pacman`, `zypper`

> ⚠️ **Disclaimer**: This project is provided as-is without warranty. It interacts with system-level package managers — use caution and review changes before running.
