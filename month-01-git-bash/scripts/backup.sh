#!/bin/bash
# =============================================================================
# Script Name : backup.sh
# Description : Backup a directory with date-timestamped archive
# Author      : Your Name
# Date        : 2025-01-15
# Usage       : ./backup.sh <source_dir> <backup_dir>
# =============================================================================
set -euo pipefail

# Функция для вывода сообщения с timestamp
log_message() {
    local msg="$1"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $msg"
}

# Проверка аргументов
if [ $# -lt 2 ]; then
    log_message "Ошибка: Требуется 2 аргумента"
    log_message "Использование: ./backup.sh <source_dir> <backup_dir>"
    exit 1
fi

SOURCE_DIR="$1"
BACKUP_DIR="$2"

log_message "Проверка источника: $SOURCE_DIR"

# Проверка существования source_dir
if [ ! -d "$SOURCE_DIR" ]; then
    log_message "Ошибка: source_dir не существует или не является директорией: $SOURCE_DIR"
    exit 1
fi

# Создание backup_dir если не существует
log_message "Проверка/создание backup_dir: $BACKUP_DIR"
if [ ! -d "$BACKUP_DIR" ]; then
    mkdir -p "$BACKUP_DIR"
    log_message "Backup_dir создан: $BACKUP_DIR"
fi

# Формирование имени файла архива
TIMESTAMP=$(date '+%Y-%m-%d_%H-%M')
ARCHIVE_NAME="backup_${TIMESTAMP}.tar.gz"
ARCHIVE_PATH="${BACKUP_DIR}/${ARCHIVE_NAME}"

log_message "Создание архива: $ARCHIVE_NAME"

# Создание архива
tar -czf "$ARCHIVE_PATH" -C "$(dirname "$SOURCE_DIR")" "$(basename "$SOURCE_DIR")"
log_message "Архив успешно создан: $ARCHIVE_PATH"

# Получение размера архива
ARCHIVE_SIZE=$(du -h "$ARCHIVE_PATH" | awk '{print $1}')
log_message "Размер архива: $ARCHIVE_SIZE"

log_message "Backup успешно выполнен"
