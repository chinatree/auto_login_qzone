#!/bin/bash
# Author  : chinatree <chinatree2012@gmail.com>
# Date    : 2014-03-10
# Version : 2.0

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
# Record Execute Log
echo "[$(date '+%Y-%m-%d %H:%M:%S')]["${SCRIPT_NAME}"] Parameters: $@" >> "${LOG_DIR}"/execute.log

usage()
{
    echo -e "`get_color "Usage:" CYANBLUE` \
    \n    ./"${SCRIPT_NAME}" [-T] [-h|--help] -u=<QQ> -p=<PASSWORD> -act=<get_token> [-appid=<appid>] \
    \n    ./"${SCRIPT_NAME}" [-T] [-h|--help] -c=<file> -act=<get_token> [-appid=<appid>] \
    \n\n`get_color "Tips:" PEACH` \
    \n    `get_fixed_width "-c=<file>" 20`Specify read QQ and PASSWORD variables from config file \
    \n    `get_fixed_width "Format:" "20"`QQ=<your qq account> \
    \n    `get_fixed_width " " "20"`PASS=<your qq password> \
    \n\n    `get_fixed_width "-act=<action>" 20`Perform the action \
    \n    `get_fixed_width "-appid=<appid>" 20`Specify application id \
    \n\n    `get_fixed_width "-T, --debug" 20`Tracking script \
    \n    `get_fixed_width "-h, --help" 20`This help \
    \n\n`get_color "Example:" RED` \
    \n    ./"${SCRIPT_NAME}" -c=etc/account.ini -act=get_token -appid=10000"
    exit 2
}

parse_arguments() {
    for arg do
        case "$arg" in
            -u=*)
                QQ=$(echo "${arg}" | sed -e 's/^[^=]*=//')
                ;;
            -p=*)
                PASS=$(echo "${arg}" | sed -e 's/^[^=]*=//')
                ;;
            -c=*)
                conf_file=$(echo "${arg}" | sed -e 's/^[^=]*=//')
                ;;
            -act=*)
                action=$(echo "${arg}" | sed -e 's/^[^=]*=//')
                ;;
            -appid=*)
                appid=$(echo "${arg}" | sed -e 's/^[^=]*=//' | sed -e 's/app//')
                ;;
            -h|--help)
                usage
                ;;
            -T|--debug)
                set -x
                ;;
        esac
    done
}

get_token()
{
    local url="http://st.yun.qq.com/ajax/loginServer/GetToken.php?mc_gtk="${GTK}"&appId="${appid}""

    ${CURL_BIN} -A "${USER_AGENT}" -b "${file_cookie}" -c "${file_cookie}" "${url}" > "${file_token}" 2> /dev/null

    if [ -f "${file_token}" ];
    then
        echo $(cat "${file_token}" | awk -F '"' '{print $(NF-1)}')
    fi
}

do_action()
{
    local action="${1:-None}"
    case "${action}" in
    get_token)
        get_token
        ;;
    *)
        usage
        ;;
    esac
}

cd "${PROJECT_ROOT}"
conf_file=''
captcha=''
action='default'
parse_arguments $@
auto_load_conf "${conf_file}"
check_accout_arg "${QQ}" "${PASS}"
accout_output_dir=""${LOG_DIR}"/"${QQ}""
file_cookie=""${accout_output_dir}"/cookie.jar"
file_token="${accout_output_dir}/token.json"
! test -f "${file_cookie}" && display_error "So sorry, The captcha file "${file_cookie}" detection is not exists, please check it and try again ..." && exit 1
SKEY=$(cat "${file_cookie}" | grep skey | awk '{print $NF}')
test -z "${SKEY}" && display_error "So sorry, The SKEY detection is empty, please login first ..." && exit 1
GTK=$(${NODE_BIN} ${ENCODE_GTK_JS} "${SKEY}")
test -z "${GTK}" && display_error "So sorry, The GTK detection is empty, please check it and try again ..." && exit 1

do_action "${action}"

exit
