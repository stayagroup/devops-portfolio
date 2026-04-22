#!/bin/bash
# =============================================================================
# Script Name : system-info.sh
# Description : Collect and display system information
# Author      : Your Name
# Date        : 2025-01-15
# Usage       : ./system-info.sh
# =============================================================================
set -euo pipefail

# Функция для вывода заголовка с аргументом
print_header() {
    local title="${1:-SYSTEM INFORMATION REPORT}"
    echo "=================================================="
    echo "  $title"
    echo "=================================================="
}

# Функция для красивого вывода подзаголовка
print_subheader() {
    echo "----------------------------------------------"
    echo "$1"
    echo "----------------------------------------------"
}

# Основная функция вывода
main() {
    print_header "System Information Report"
    echo "Generated at: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "Host: $(hostname)"
    echo ""

    # 1. Информация об ОС
    print_subheader "Operating System Information"
    echo "Hostname      : $(hostname)"
    echo "Kernel        : $(uname -r)"
    echo "Architecture  : $(uname -m)"
    echo "Platform      : $(uname -p)"
    echo "OS Name       : $(grep PRETTY_NAME /etc/os-release | cut -d'=' -f2 | tr -d '"' | tr -d "'")"
    echo ""

    # 2. Информация о CPU
    print_subheader "CPU Information"
    echo "Model         : $(lscpu | grep '^Model name:' | cut -d: -f2 | xargs)"
    echo "Cores         : $(lscpu | grep '^CPU(s):' | awk '{print $2}')"
    echo "Threads       : $(lscpu | grep '^Thread(s):' | awk '{print $2}')"
    echo "Socket        : $(lscpu | grep '^Socket(s):' | awk '{print $2}')"
    echo "CPU Usage     : $(top -bn1 | grep 'Cpu(s)' | awk '{printf "%.0f%%", 100-$8}')"
    echo ""

    # 3. Информация о памяти
    print_subheader "Memory Information"
    echo "Total Memory  : $(free -h | grep Mem | awk '{print $2}')"
    echo "Used Memory   : $(free | grep Mem | awk '{print $3}')"
    echo "Available     : $(free | grep Mem | awk '{print $4}')"
    echo "Usage         : $(free | grep Mem | awk '{printf "%.1f%%", $3/$2 * 100}')"
    echo "Buffers/Cache : $(free -h | grep Mem | awk '{print $6}')"
    echo ""

    # 4. Информация о дисках
    print_subheader "Disk Usage (by root)"
    df -h /
    echo ""

    # 5. Сетевые подключения
    print_subheader "Network Interfaces"
    ip -br addr show
    echo ""

    # 6. Загрузочная информация
    print_subheader "System Uptime"
    uptime
    echo ""

    # 7. Логи (последние ошибки)
    print_subheader "Recent System Errors (dmesg)"
    if [ -t 1 ]; then
        dmesg 2>/dev/null | grep -i "error\|fail" | tail -5
    fi
    echo ""

    print_header
    echo "End of System Information Report"
    echo "=================================================="
}

# Запуск основного выполнения
main
