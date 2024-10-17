#!/bin/bash

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
RESET='\033[0m'

check_cpu_usage() {
    cpu_usage=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
    echo "$cpu_usage"
}

check_memory_usage() {
    mem_used=$(free -h | awk '/^Mem/ {print $3}')
    mem_total=$(free -h | awk '/^Mem/ {print $2}')
    mem_percent=$(free | awk '/^Mem/ {printf "%.2f", $3/$2 * 100}')
    
    echo "$mem_used/$mem_total ($mem_percent%)"
}

check_disk_usage() {
    df -h | awk 'NR>1 {printf "%s: %s/%s (%.2f%%)\n", $NF, $3, $2, $3/$2 * 100}'
}

clear
echo -e "${GREEN}*** Live System Monitoring Report ***${RESET}"

while true; do
    cpu_usage=$(check_cpu_usage)
    if (( $(echo "$cpu_usage > 80" | bc -l) )); then
        cpu_output="${RED}CPU Usage: $cpu_usage% (High Usage!)${RESET}"
    else
        cpu_output="${GREEN}CPU Usage: $cpu_usage%${RESET}"
    fi

    mem_usage=$(check_memory_usage)
    mem_percent=$(echo "$mem_usage" | awk -F '[(]' '{print $2}' | awk '{print $1}' | sed 's/%//')
    if (( $(echo "$mem_percent > 80" | bc -l) )); then
        mem_output="${RED}Used Memory: ${YELLOW}$mem_usage${RESET} (High Usage!)"
    else
        mem_output="${GREEN}Used Memory: ${YELLOW}$mem_usage${RESET}"
    fi

    disk_output=$(check_disk_usage)

    clear
    echo -e "${GREEN}*** Live System Monitoring Report ***${RESET}"
    echo -e "${CYAN}----- CPU Usage -----${RESET}"
    echo -e "$cpu_output"
    echo
    echo -e "${CYAN}----- Memory Usage -----${RESET}"
    echo -e "$mem_output"
    echo
    echo -e "${CYAN}----- Disk Usage -----${RESET}"
    echo -e "$disk_output"
    echo

    echo -e "${GREEN}*** End of Report ***${RESET}"
    sleep 2  
done
