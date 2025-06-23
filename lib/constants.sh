CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/tstall"
DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/tstall"
LOG_DIR="${XDG_RUNTIME_DIR:-/tmp}/tstall/logs"

CONFIG_FILE="$CONFIG_DIR/config.conf"
DB_FILE="$DATA_DIR/tstall.db"
SCHEMA_FILE="$DATA_DIR/init.sql"

mkdir -p "$CONFIG_DIR" "$DATA_DIR" "$LOG_DIR"

[[ -f "$CONFIG_FILE" ]] && source "$CONFIG_FILE"