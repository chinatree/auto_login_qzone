#!/bin/bash
# Author  : chinatree <chinatree2012@gmail.com>
# Date    : 2014-03-10
# Version : 1.0

# [global]
SCRIPT_PATH=$(cd "$(dirname "$0")"; pwd)
SCRIPT_NAME=$(basename "$0")
PROJECT_ROOT="$(cd "${SCRIPT_PATH}"/../; pwd)"
CONFIG_DIR=""${PROJECT_ROOT}"/etc"
CONFIG_FILE=""${CONFIG_DIR}"/config.ini"
PARA_NUM="$#"

if test -f "${CONFIG_FILE}"
then
    . "${CONFIG_FILE}"
else
    echo "The file "${CONFIG_FILE}" not exists, please check it and try again!"
    exit 1
fi

load_file "${COMMON_FILE}"
! test -d "${LOG_DIR}" && mkdir -p "${LOG_DIR}"

chmod -R 777 "${LOG_DIR}"
find "${PROJECT_ROOT}" -name "*.sh" | xargs chmod 755

exit
