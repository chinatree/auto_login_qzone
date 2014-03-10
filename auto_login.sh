#!/bin/bash
# Author  : chinatree <chinatree2012@gmail.com>
# Date    : 2014-03-10
# Version : 2.0

# [global]
SCRIPT_PATH=$(cd "$(dirname "$0")"; pwd)
SCRIPT_NAME=$(basename "$0")
PROJECT_ROOT="$(cd "${SCRIPT_PATH}"; pwd)"
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
    \n    ./"${SCRIPT_NAME}" [-T] [-h|--help] -u=<QQ> -p=<PASSWORD> -act=<auto|get_captcha_pic|login_qzone> [-code=<captcha>] \
    \n    ./"${SCRIPT_NAME}" [-T] [-h|--help] -c=<file> -act=<auto|get_captcha_pic|login_qzone> [-code=<captcha>] \
    \n\n`get_color "Tips:" PEACH` \
    \n    `get_fixed_width "-c=<file>" 20`Specify read QQ and PASSWORD variables from config file \
    \n    `get_fixed_width "Format:" "20"`QQ=<your qq account> \
    \n    `get_fixed_width " " "20"`PASS=<your qq password> \
    \n\n    `get_fixed_width "-act=<action>" 20`Perform the action \
    \n    `get_fixed_width "-code=<captcha>" 20`Verification code \
    \n\n    `get_fixed_width "-T, --debug" 20`Tracking script \
    \n    `get_fixed_width "-h, --help" 20`This help \
    \n\n`get_color "Example:" RED` \
    \n    ./"${SCRIPT_NAME}" -c=etc/account.ini -act=auto \
    \n    or \
    \n    ./"${SCRIPT_NAME}" -c=etc/account.ini -act=get_captcha_pic \
    \n    ./"${SCRIPT_NAME}" -c=etc/account.ini -act=login_qzone -code=6666"
    exit 2
}

# Parse args
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
            -code=*)
                captcha=$(echo "${arg}" | sed -e 's/^[^=]*=//')
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

# Get captcha string
login_get_captcha_str()
{
    local url="http://check.ptlogin2.qq.com/check?uin="${QQ}"&appid=549000912&ptlang=2052&r=0.26376"

    ${CURL_BIN} -A "${USER_AGENT}" -b "${file_cookie}" -c "${file_cookie}" "${url}" > "${file_captcha}" 2> /dev/null
    return 0
}

# Get captcha picture
login_get_captcha_pic()
{
    local url="http://captcha.qq.com/getimage?uin="${QQ}"&aid=549000912&ptlang=2052&r=0.26376"

    ${CURL_BIN} -o "${image_captcha}" -A "${USER_AGENT}" -b "${file_cookie}" -c "${file_cookie}" "${url}" 2> /dev/null
    #echo -n "${url}"
    echo -n "${QQ}"
    return 0
}

# This is check the captcha is string or image:
# If the verification code is a string, it is made of ! at the beginning of the string
check_captcha_type()
{
    [ ! -f "${file_captcha}" ] && display_error "The verify file "${file_captcha}" is not exists, login interrupt ..." && exit 1
    local normal_ver=$(cat "${file_captcha}" | awk -F "\'" '{print $4}' | grep ^!)
    [ -z "${normal_ver}" ] && display_error "Verification code is perhaps image verification code, login interrupt ..." && exit 1
    return 0
}

# Get QQ UIN
# Another way: node saltUin.js <QQ>
# Notice: saltUin.js only support QQ/QQ Mail
get_qq_uin()
{
    local file="${1:-None}"
    [ -f "${file}" ] && echo $(cat "${file_captcha}" | awk -F "'" '{print $6}' | sed 's/\\x//g') && return 0
    return 1
}

# Check encryption password
check_encode_password()
{
    [ -z "${Q_ENCODE_P}" ] && display_error "The password encode failed, login interrupt ..." && exit 1
    return 0
}

# Login
login_qzone()
{
    local u="${QQ}"
    local p="${Q_ENCODE_P}"
    local verifycode="${captcha}"
    local url="http://ptlogin2.qq.com/login?ptlang=2052&u="${u}"&p="${p}"&verifycode="${verifycode}"&aid=549000912&u1=http%3A%2F%2Fqzs.qq.com%2Fqzone%2Fv5%2Floginsucc.html%3Fpara%3Dizone&ptredirect=1&h=1&g=1&t=1&from_ui=1&dumy=&fp=loginerroralert&action=6-28-1393986285918&dummy=&js_type=1&js_ver=10069"

    ${CURL_BIN} -A "${USER_AGENT}" -b "${file_cookie}" -c "${file_cookie}" "${url}" > "${file_result}" 2> /dev/null
    return 0
}

# Check login result
check_login_result() {
    local retPrint="${1:-None}"
    [ ! -f "${file_result}" ] && display_error "The verify file "${file_result}" is not exists, login interrupt ..." && exit 1
    local login_result=$(cat "${file_result}" | grep "ptuiCB('0'.*)")
    if [ -z "${login_result}" ]; then
        cat "${file_result}"
        display_error "So sorry, login failed, you can check and try again ..."
        exit 1
    else
        [ "${retPrint}" != "None" ] && echo -n 'SUCC'
    fi
    return 0
}

do_action()
{
    local action="${1:-None}"
    case "${action}" in
    auto)
        # 获取默认字符串验证码
        login_get_captcha_str
        # 检测是否切为图形验证码
        check_captcha_type
        # 截取 4 位数的字符串验证码
        ! test -f "${file_captcha}" && display_error "So sorry, The file "${file_captcha}" detection is not exists, please try again ..." && exit 1
        captcha=$(cat "${file_captcha}" | awk -F "'" '{print $4}')
        # 取得 QQ UIN
        QQ_UIN=$(get_qq_uin "${file_captcha}")
        # 采用 node 加密密码
        # 注：这里采用 UIN 则支持 QQ、邮箱、手机多种帐号类型
        Q_ENCODE_P=$(${NODE_BIN} ${ENCODE_PASS_JS} "${QQ_UIN}" "${PASS}" "${captcha}")
        # 检测加密是否正常
        check_encode_password
        # 登录 qzone
        login_qzone "${QQ}" "${Q_ENCODE_P}" "${captcha}"
        # 检查登录结果
        check_login_result
        return 0
        ;;
    get_captcha_pic)
        # 为了支持 QQ、邮箱、手机多种帐号类型，从默认字符串验证码接口取得 QQ UIN
        # 如果仅指定其中一种，可省略
        login_get_captcha_str
        # 获取验证码图片
        login_get_captcha_pic
        ;;
    login_qzone)
        test -z "${captcha}" && display_error "So sorry, The captcha detection is empty, please try again ..." && exit 1
        QQ_UIN=$(cat "${file_captcha}" | awk -F "'" '{print $6}' | sed 's/\\x//g')
        Q_ENCODE_P=$(${NODE_BIN} ${ENCODE_PASS_JS} "${QQ_UIN}" "${PASS}" "${captcha}")
        check_encode_password
        login_qzone "${QQ}" "${Q_ENCODE_P}" "${captcha}"
        check_login_result '1'
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

! test -d "${accout_output_dir}" && mkdir -p "${accout_output_dir}"
file_captcha=""${accout_output_dir}"/captcha.json"
image_captcha=""${accout_output_dir}"/captcha.gif"
file_cookie=""${accout_output_dir}"/cookie.jar"
file_result=""${accout_output_dir}"/result.json"
do_action "${action}"

#/*----------------------------------------  EXAMPLE  ----------------------------------------*/
example_captcha_str()
{
    #Example:
    run_start_time=$(date '+%Y-%m-%d %H:%M:%S')
    echo "Starting login `get_color "${QQ}" GOLDYELLOW` at "${run_start_time}""
    echo -n "Auto login `get_color ""${QQ}"" PEACH` is "
    local action="auto"
    do_action "${action}"
    get_exit_code $?
    echo "You can use "${file_cookie}" to do other things."
    run_end_time=$(date '+%Y-%m-%d %H:%M:%S')
    echo "Finish at "${run_end_time}""
}

example_captcha_pic()
{
    #Example:
    Step No.1, get captcha picture
    local action="get_captcha_pic"
    do_action "${action}"
    Step No.2, login
    run_start_time=$(date '+%Y-%m-%d %H:%M:%S')
    echo "Starting login `get_color "${QQ}" GOLDYELLOW` at "${run_start_time}""
    echo -n "Login `get_color ""${QQ}"" PEACH`(captcha="${captcha}") is "
    local action="login_qzone"
    do_action "${action}"
    get_exit_code $?
    echo "You can use "${file_cookie}" to do other things."
    run_end_time=$(date '+%Y-%m-%d %H:%M:%S')
    echo "Finish at "${run_end_time}""
}

# example_captcha_str
# example_captcha_pic
#/*----------------------------------------  EXAMPLE  ----------------------------------------*/

exit
