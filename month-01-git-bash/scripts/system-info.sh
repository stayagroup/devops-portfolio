#!/bin/bash
# =============================================================================
# Script Name : system-info.sh
# Description : Collect and display system information
# Author      : Your Name
# Date        : 2025-01-15
# Usage       : ./system-info.sh
# =============================================================================
set -euo pipefail

# Функция для красивого вывода заголовка
print_header() {
    echo "=================================================="
    echo "         SYSTEM INFORMATION REPORT"
    echo "=================================================="
    echo "Generated at: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "=================================================="
    echo ""
}

# Функция для красивого вывода подзаголовка
print_subheader() {
    echo "----------------------------------------------"
    echo "$1"
    echo "----------------------------------------------"
}

# Функция для вывода информации в столбцы
print_info_columns() {
    local cols=("$@")
    local width=50
    local fmt="[%s]"
    local i
    local total_cols=${#cols[@]}
    local col_width=$((width / total_cols))
    for i in "${!cols[@]}"; do
        echo "${cols[i]}" | head -c $col_width
        printf '%s'
    done
}

# Основная функция вывода
main() {
    print_header

    # 1. Информация об ОС
    print_subheader "Operating System Information"
    echo "Hostname     : $(hostname)"
    echo "Kernel       : $(uname -r)"
    echo "OS Name      : $(cat /etc/os-release | grep PRETTY_NAME | cut -d'=' -f2 | tr -d '"' | tr -d "'" )"
    echo "Architecture : $(uname -m)"
    echo "Platform     : $(uname -p)"
    echo ""

    # 2. Информация о CPU
    print_subheader "CPU Information"
    echo "Model         : $(lscpu | grep 'Model name' | cut -d: -f2 | xargs)"
    echo "Cores         : $(lscpu | grep 'CPU(s)' | awk '{print $2}')"
    echo "Threads       : $(lscpu | grep 'Thread(s)' | awk '{print $2}')"
    echo "Socket        : $(lscpu | grep 'Socket(s)' | awk '{print $2}')"
    echo "CPU Usage     : $(top -bn1 | grep 'Cpu(s)' | awk '{printf "%.0f", $8}')%"
    echo ""

    # 3. Информация о памяти
    print_subheader "Memory Information"
    echo "Total Memory  : $(free -h | grep Mem | awk '{print $2}')"
    echo "Available     : $(free -h | grep Mem | awk '{print $7}')"
    echo "Used          : $(free -h | grep Mem | awk '{print $3}')"
    echo "Usage         : $(free -h | grep Mem | awk '{printf "%.0f%%", $4 / $2 * 100}')"
    echo "Buffer/Cache  : $(free -h | grep Mem | awk '{print $4}')"
    echo ""

    # 4. Информация о дисках
    print_subheader "Disk Information"
    echo "=================================================="
    print_header "Disk Usage (by root)"
    df -h /
    print_subheader "Filesystems"
    df -h
    echo ""

    # 5. Сетевые подключения
    print_subheader "Network Interfaces"
    ip -br addr show
    echo ""

    # 6. Загрузка процессов
    print_subheader "Top Processes (CPU & Memory)"
    echo "=================================================="
    print_header "Top 10 Processes by CPU Usage"
    top -bn1 | head -20
    echo ""

    # 7. Загрузочная информация
    print_subheader "Boot Information"
    uptime

    # 8. Логи
    print_subheader "System Logs (Last 5 Errors)"
    echo "=================================================="
    print_header "Recent System Errors (dmesg)"
    dmesg 2>/dev/null | grep -i "error\|fail" | tail -5
    echo ""

    print_header
    echo "End of System Information Report"
    echo "=================================================="
}

# Запуск основного выполнения
main
