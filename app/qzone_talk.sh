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
load_file "${CONFIG_DIR}"/qzone_talk.ini
! test -d "${LOG_DIR}" && mkdir -p "${LOG_DIR}"
# Record Execute Log
echo "[$(date '+%Y-%m-%d %H:%M:%S')]["${SCRIPT_NAME}"] Parameters: $@" >> "${LOG_DIR}"/execute.log

usage()
{
    echo -e "`get_color "Usage:" CYANBLUE` \
    \n    ./"${SCRIPT_NAME}" [-T] -u=<QQ> -p=<PASSWORD> [-act=<post|...|emoticon_post>] \
    \n    ./"${SCRIPT_NAME}" [-T] -c=<file> [-act=<post|...|emoticon_post>] \
    \n    ./"${SCRIPT_NAME}" [-h|--help] \
    \n\n`get_color "Tips:" PEACH` \
    \n    `get_fixed_width "-c=<file>" 20`Specify read QQ and PASSWORD variables from config file \
    \n    `get_fixed_width "Format:" "20"`QQ=<your qq account> \
    \n    `get_fixed_width " " "20"`PASS=<your qq password> \
    \n\n    `get_fixed_width "-act=<action>" 20`Perform the action, as \
    \n    `get_fixed_width " " "20"`post, emoticon_post, rich_emoticon_post, rich_pic_emoticon_post \
    \n    `get_fixed_width " " "20"`list, list_tid, delete_by_tid \
    \n\n    `get_fixed_width "-T, --debug" 20`Tracking script \
    \n    `get_fixed_width "-h, --help" 20`This help \
    \n\n`get_color "Example:" RED` \
    \n    ./"${SCRIPT_NAME}" -c=etc/account.ini -act=list"
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
            -tid=*)
                tid=$(echo "${arg}" | sed -e 's/^[^=]*=//')
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

list_talk()
{
    local post_data=""
    local url="http://taotao.qq.com/cgi-bin/emotion_cgi_get_mix_v6?uin="${QQ}"&ftype=0&sort=0&pos=0&num=20&replynum=100&g_tk="${GTK}"&callback=_preloadCallback&code_version=1&format=jsonp"
    local tmp_file="${qzone_talk_dir}/list_talk.txt"

    ${CURL_BIN} --max-time ${CURL_MAX_TIME} -o "${tmp_file}" -A "${USER_AGENT}" -b "${file_cookie}" -c "${file_cookie}" -d "${post_data}" "${url}" 2>/dev/null
    less "${tmp_file}" | ${PHP_BIN} ${PROJECT_ROOT}/app/qzone_talk.php msglist
}

list_tid () {
    local tmp_file="${qzone_talk_dir}/list_talk.txt"
    less "${tmp_file}" | ${PHP_BIN} ${PROJECT_ROOT}/app/qzone_talk.php 'list_tid'
}

talk_post()
{
    local post_data="qzreferrer="${qz_referrer}"%26pfid%3D2%26qz_ver%3D6%26appcanvas%3D0%26qz_style%3Dv6%2F88%26params%3D%26entertime%3D"${POST_RANDOM}"%26canvastype%3D&con="${normal_content}"&feedversion=1&ver=1&private=0&code_version=1&format=fs&out_charset=UTF-8&hostuin="${QQ}""
    local url="http://taotao.qq.com/cgi-bin/emotion_cgi_publish_v6?g_tk=${GTK}"
    local tmp_file="${qzone_talk_dir}/talk_post.txt"

    ${CURL_BIN} --max-time ${CURL_MAX_TIME} -o "${tmp_file}" -A "${USER_AGENT}" -b "${file_cookie}" -c "${file_cookie}" -d "${post_data}" "${url}" 2>/dev/null
}

emoticon_post()
{
    local post_data="qzreferrer="${qz_referrer}"%26pfid%3D2%26qz_ver%3D6%26appcanvas%3D0%26qz_style%3Dv6%2F88%26params%3D%26entertime%3D"${POST_RANDOM}"%26canvastype%3D&con="${emoticon_content}"&feedversion=1&ver=1&private=0&code_version=1&format=fs&out_charset=UTF-8&hostuin="${QQ}""
    local url="http://taotao.qq.com/cgi-bin/emotion_cgi_publish_v6?g_tk=${GTK}"
    local tmp_file="${qzone_talk_dir}/emoticon_post.txt"

    ${CURL_BIN} --max-time ${CURL_MAX_TIME} -o "${tmp_file}" -A "${USER_AGENT}" -b "${file_cookie}" -c "${file_cookie}" -d "${post_data}" "${url}" 2>/dev/null
}

rich_emoticon_post()
{
    local post_data="qzreferrer="${qz_referrer}"&richtype=6&richval=%7B%22%24type%22%3A%22magicEmoticon%22%2C%22id%22%3A"${magic_emoticon_id}"%7D&special_url=&subrichtype=9&who=1&con="${rich_emoticon_content}"&feedversion=1&ver=1&private=0&code_version=1&format=fs&out_charset=UTF-8&hostuin="${QQ}""
    local url="http://taotao.qq.com/cgi-bin/emotion_cgi_publish_v6?g_tk=${GTK}"
    local tmp_file="${qzone_talk_dir}/rich_emoticon_post.txt"

    ${CURL_BIN} --max-time ${CURL_MAX_TIME} -o "${tmp_file}" -A "${USER_AGENT}" -b "${file_cookie}" -c "${file_cookie}" -d "${post_data}" "${url}" 2>/dev/null
}

rich_pic_emoticon_post()
{
    local post_data="qzreferrer=http%3A%2F%2Fuser.qzone.qq.com%2F2631483726&richtype=1&richval=fileName%3D"${rich_pic_filename}"%26width%3D100%26height%3D100%26who%3D2%26pic_type%3D2&special_url=&subrichtype=2&who=1&con="${rich_pic_emoticon_content}"&feedversion=1&ver=1&private=0&code_version=1&format=fs&out_charset=UTF-8&hostuin="${QQ}""
    local url="http://taotao.qq.com/cgi-bin/emotion_cgi_publish_v6?g_tk=${GTK}"
    local tmp_file="${qzone_talk_dir}/rich_pic_emoticon_post.txt"

    ${CURL_BIN} --max-time ${CURL_MAX_TIME} -o "${tmp_file}" -A "${USER_AGENT}" -b "${file_cookie}" -c "${file_cookie}" -d "${post_data}" "${url}" 2>/dev/null
}

delete_by_tid()
{
    test -z "${tid}" && display_error "So sorry, The tid detection is empty, please check it and try again ..." && exit 2

    local post_data="qzreferrer="${qz_referrer}"%26pfid%3D2%26qz_ver%3D6%26appcanvas%3D0%26qz_style%3Dv6%2F88%26params%3D%26entertime%3D"${POST_RANDOM}"%26canvastype%3D&hostuin="${QQ}"&tid="${tid}"&t1_source=1&code_version=1&format=fs&out_charset=UTF-8"
    local url="http://taotao.qq.com/cgi-bin/emotion_cgi_delete_v6?g_tk=${GTK}"
    local tmp_file="${qzone_talk_dir}/delete_by_tid.txt"

    ${CURL_BIN} --max-time ${CURL_MAX_TIME} -o "${tmp_file}" -A "${USER_AGENT}" -b "${file_cookie}" -c "${file_cookie}" -d "${post_data}" "${url}" 2>/dev/null
}

do_action()
{
    local action="${1:-None}"
    case "${action}" in
    post)
        talk_post
        ;;
    emoticon_post)
        emoticon_post
        ;;
    rich_emoticon_post)
        rich_emoticon_post
        ;;
    rich_pic_emoticon_post)
        rich_pic_emoticon_post
        ;;
    list_tid)
        list_tid
        ;;
    delete_by_tid)
        delete_by_tid
        ;;
    list)
        list_talk
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
qzone_talk_dir=""${LOG_DIR}"/"${QQ}"/qzone_talk"
mkdir -p "${qzone_talk_dir}"
file_cookie=""${accout_output_dir}"/cookie.jar"
! test -f "${file_cookie}" && display_error "So sorry, The captcha file "${file_cookie}" detection is not exists, please check it and try again ..." && exit 1
SKEY=$(cat "${file_cookie}" | grep skey | awk '{print $NF}')
test -z "${SKEY}" && display_error "So sorry, The SKEY detection is empty, please login first ..." && exit 1
GTK=$(${NODE_BIN} ${ENCODE_GTK_JS} "${SKEY}")
test -z "${GTK}" && display_error "So sorry, The GTK detection is empty, please check it and try again ..." && exit 1

do_action "${action}"

exit
