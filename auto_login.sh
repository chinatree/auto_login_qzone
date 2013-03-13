#!/bin/bash
# author   : chinatree <chinatree2012@gmail.com>
# date     : 2013-01-09
# version  : 1.0.2

# [global]
SCRIPT_PATH=$(cd "$(dirname "$0")"; pwd)
SCRIPT_NAME=$(basename "$0")
COMMON_FILE=""${SCRIPT_PATH}"/common.sh"
PARA_NUM="$#"
USER_AGENT="Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 5.1; Trident/4.0; QQDownload 734; .NET CLR 2.0.50727; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729; .NET CLR 1.1.4322)"
ENCODE_PASS_JS="${SCRIPT_PATH}/encode_password.js"

if [ ! -f "${COMMON_FILE}" ];
then
    echo "The common function file "${COMMON_FILE}" not exists, please check it and try again!"
    exit 1
else
    . "${COMMON_FILE}"
fi

function usage () {
    echo -e "`get_color "Usage:" GOLDYELLOW` \
    \n    ./"${SCRIPT_NAME}" <QQ> <QQ_PASSWORD> \
    \n    ./"${SCRIPT_NAME}" -c <FILE> \
    \n\n`get_color "Tips:" GOLDRED` \
    \n    Config file format: \
    \n    QQ=<your qq account> \
    \n    PASS=<your qq password>"
    exit 2
}

function auto_login_qq () {
    # $1 -> QQ or MAIL or PHONE, now support QQ, MAIL
    # $2 -> QQ PASSWORD
    local QQ="$1"
    local PASS="$2"
    local get_VC_url="http://check.ptlogin2.qq.com/check?uin="${QQ}"&appid=15000101&ptlang=2052&r=0.26376"

    qq_vc_file="${SCRIPT_PATH}/verify/${QQ}_VC.txt"
    qq_cookie_file="${SCRIPT_PATH}/cookie/${QQ}.cookie.txt"
    qq_result_file="${SCRIPT_PATH}/result/${QQ}.result.txt"

    /usr/bin/curl -A "${USER_AGENT}" -b "${qq_cookie_file}" -c "${qq_cookie_file}" "${get_VC_url}" > ${qq_vc_file} 2> /dev/null
    chk_is_problem "verifycode"

    QQ_VC=$(cat "${qq_vc_file}"| awk -F "'" '{print $4}')
    QQ_UIN=$(cat "${qq_vc_file}" | awk -F "'" '{print $6}' | sed 's/\\x//g')

    Q_ENCODE_P=$(node ${ENCODE_PASS_JS} "${QQ_UIN}" "${PASS}" "${QQ_VC}")
    chk_is_problem "encode"

    /usr/bin/curl -A "${USER_AGENT}" -b "${qq_cookie_file}" -c "${qq_cookie_file}" "http://ptlogin2.qq.com/login?ptlang=2052&u="${QQ}"&p="${Q_ENCODE_P}"&verifycode="${QQ_VC}"&css=http://imgcache.qq.com/ptcss/b2/sjpt/549000912/qzonelogin_ptlogin.css&mibao_css=m_qzone&aid=549000912&u1=http%3A%2F%2Fqzs.qq.com%2Fqzone%2Fv5%2Floginsucc.html%3Fpara%3Dizone&ptredirect=1&h=1&from_ui=1&dumy=&fp=loginerroralert&action=1-2-51486&g=1&t=1&dummy=&js_type=2&js_ver=10009" > "${qq_result_file}" 2> /dev/null
    chk_is_problem "login" "${QQ}"
}

function chk_para () {
    # $1 -> QQ or MAIL or PHONE, now support QQ, MAIL
    # $2 -> QQ PASSWORD
    if [ -z "$1" ] || [ -z "$2" ]; then
        echo "`get_color "The QQ or PASSWORD is empty, please check it and try again ..." RED`"
        exit 2
    fi
}

function chk_is_problem () {
    # $1 -> action
    local action="$1"
    if [ "${action}" == "verifycode" ]; then
        if [ ! -f "${qq_vc_file}" ]; then
            echo "`get_color "The verify file "${qq_vc_file}" is not exists, login interrupt ..." RED`"
            exit 1
        fi
        local normal_ver=$(cat "${qq_vc_file}" | awk -F "\'" '{print $4}' | grep ^!)
        if [ -z "${normal_ver}" ]; then
            echo "`get_color "Verification code is perhaps image verification code, login interrupt ..." RED`"
			exit 1
        fi
        return 0
    fi

    if [ "${action}" == "login" ]; then
        if [ ! -f "${qq_result_file}" ]; then
            echo "`get_color "The verify file "${qq_result_file}" is not exists, login interrupt ..." RED`"
            exit 1
        fi

        local login_result=$(cat "${qq_result_file}" | grep "ptuiCB('0'.*)")
        if [ -n "${login_result}" ]; then
            echo "Login `get_color "$2" BOLD` is [`get_color " SUCCESS " GREEN`]"
            echo "you can use "${qq_cookie_file}" to do other things."
        else
            cat "${qq_result_file}"
            echo "`get_color "So sorry, login failed, you can check and try again ..." RED`"
			exit 1
        fi
        return 0
    fi

    if [ "${action}" == "encode" ]; then    
        if [ -z "${Q_ENCODE_P}" ]; then
            echo "`get_color "The password encode failed, login interrupt ..." RED`"
            exit 1
        fi
        return 0
    fi
}

if [ "${PARA_NUM}" -lt "2" ]; then
    usage
fi

if [ "$1" == "-c" ]; then
    if [ -f "$2" ]; then
        rela_path=$(echo $2 | grep ^./)
        if [ -z "${rela_path}" ]; then
            source ${SCRIPT_PATH}/$2
        else
            source $2
        fi
    else
        echo -e "The config file $2 is not exists, please checek it and try again!\n"
        usage
    fi
else
    QQ="$1"
    PASS="$2"
fi

run_start_time=$(date '+%Y-%m-%d %H:%M:%S')
echo "Starting login `get_color "${QQ}" GOLDYELLOW` at "${run_start_time}""
chk_para "${QQ}" "${PASS}"
cd ${SCRIPT_PATH}
mkdir -p {cookie,result,verify}
auto_login_qq "${QQ}" "${PASS}"

run_end_time=$(date '+%Y-%m-%d %H:%M:%S')
echo "Finish at "${run_end_time}""