spin() {
    local spinner=('|' '/' '-' '\\')
    local i=0
    while true; do
        printf "\r${spinner[i]}"
        i=$(( (i+1) % ${#spinner[@]} ))
        sleep 0.1
    done
}