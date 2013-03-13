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
POST_TIME=$(date +%s)
POST_RANDOM="${POST_TIME}${RANDOM:0:3}"

if [ ! -f "${COMMON_FILE}" ];
then
    echo "The common function file "${COMMON_FILE}" not exists, please check it and try again!"
    exit 1
else
    . "${COMMON_FILE}"
fi

function usage () {
    echo -e "`get_color "Usage:" GOLDYELLOW` \
    \n    ./"${SCRIPT_NAME}" <QQ> <CONTENT> [post|emoticon_post|rich_emoticon_post|rich_pic_emoticon_post] \
    \n    ./"${SCRIPT_NAME}" -c <FILE> [post|emoticon_post|rich_emoticon_post|rich_pic_emoticon_post] \
    \n\n`get_color "Tips:" GOLDRED` \
    \n    Config file format: \
    \n    QQ=<your qq account> \
    \n    PASS=<your qq password>"
    exit 2
}

if [ "${PARA_NUM}" -lt "2" ]; then
    usage
fi

function list () {
    POST_DATA=""
    POST_URL="http://taotao.qq.com/cgi-bin/emotion_cgi_get_mix_v6?uin="${QQ}"&ftype=0&sort=0&pos=0&num=20&replynum=100&g_tk="${GTK}"&callback=_preloadCallback&code_version=1&format=jsonp"

    /usr/bin/curl -A "${USER_AGENT}" -b "${COOKIE_FILE}" -c "${COOKIE_FILE}" -d "${POST_DATA}" "${POST_URL}"
}

function list_tid () {
    list > "${SCRIPT_PATH}"/list.txt 2> /dev/null
    local list_tid=$(cat "${SCRIPT_PATH}"/list.txt | sed 's/\("tid":"[0-9a-zA-z]\{24\}"\)/\n\1\n/g' | grep tid | awk -F '"' '{print $4}')
    echo "${list_tid}"
}

function post () {
    POST_DATA="qzreferrer="${qz_referrer}"%26pfid%3D2%26qz_ver%3D6%26appcanvas%3D0%26qz_style%3Dv6%2F88%26params%3D%26entertime%3D"${POST_RANDOM}"%26canvastype%3D&con="${normal_content}"&feedversion=1&ver=1&private=0&code_version=1&format=fs&out_charset=UTF-8&hostuin="${QQ}""
    POST_URL="http://taotao.qq.com/cgi-bin/emotion_cgi_publish_v6?g_tk=${GTK}"

    /usr/bin/curl -A "${USER_AGENT}" -b "${COOKIE_FILE}" -c "${COOKIE_FILE}" -d "${POST_DATA}" "${POST_URL}"
}

function emoticon_post () {
    POST_DATA="qzreferrer="${qz_referrer}"%26pfid%3D2%26qz_ver%3D6%26appcanvas%3D0%26qz_style%3Dv6%2F88%26params%3D%26entertime%3D"${POST_RANDOM}"%26canvastype%3D&con="${emoticon_content}"&feedversion=1&ver=1&private=0&code_version=1&format=fs&out_charset=UTF-8&hostuin="${QQ}""
    POST_URL="http://taotao.qq.com/cgi-bin/emotion_cgi_publish_v6?g_tk=${GTK}"
    /usr/bin/curl -A "${USER_AGENT}" -b "${COOKIE_FILE}" -c "${COOKIE_FILE}" -d "${POST_DATA}" "${POST_URL}"
}

function rich_emoticon_post () {
    POST_DATA="qzreferrer="${qzReferrer}"&richtype=6&richval=%7B%22%24type%22%3A%22magicEmoticon%22%2C%22id%22%3A"${magic_emoticon_id}"%7D&special_url=&subrichtype=9&who=1&con="${rich_emoticon_content}"&feedversion=1&ver=1&private=0&code_version=1&format=fs&out_charset=UTF-8&hostuin="${QQ}""
    POST_URL="http://taotao.qq.com/cgi-bin/emotion_cgi_publish_v6?g_tk=${GTK}"

    /usr/bin/curl -A "${USER_AGENT}" -b "${COOKIE_FILE}" -c "${COOKIE_FILE}" -d "${POST_DATA}" "${POST_URL}"
}

function rich_pic_emoticon_post () {
    POST_DATA="qzreferrer=http%3A%2F%2Fuser.qzone.qq.com%2F2631483726&richtype=1&richval=fileName%3D"${rich_pic_filename}"%26width%3D100%26height%3D100%26who%3D2%26pic_type%3D2&special_url=&subrichtype=2&who=1&con="${rich_pic_emoticon_content}"&feedversion=1&ver=1&private=0&code_version=1&format=fs&out_charset=UTF-8&hostuin="${QQ}""
    POST_URL="http://taotao.qq.com/cgi-bin/emotion_cgi_publish_v6?g_tk=${GTK}"

    /usr/bin/curl -A "${USER_AGENT}" -b "${COOKIE_FILE}" -c "${COOKIE_FILE}" -d "${POST_DATA}" "${POST_URL}"
}

function delete_by_tid () {
    local tid="$1"
    if [ -z "${tid}" ]; then
        exit 2
    fi
    POST_DATA="qzreferrer="${qzReferrer}"%26pfid%3D2%26qz_ver%3D6%26appcanvas%3D0%26qz_style%3Dv6%2F88%26params%3D%26entertime%3D"${POST_RANDOM}"%26canvastype%3D&hostuin="${QQ}"&tid="${tid}"&t1_source=1&code_version=1&format=fs&out_charset=UTF-8"
    POST_URL="http://taotao.qq.com/cgi-bin/emotion_cgi_delete_v6?g_tk=${GTK}"

    /usr/bin/curl -A "${USER_AGENT}" -b "${COOKIE_FILE}" -c "${COOKIE_FILE}" -d "${POST_DATA}" "${POST_URL}"
}

if [ "$1" == "-c" ]; then
    if [ -f "$2" ]; then
        rela_path=$(echo $2 | egrep '^./|^/')
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
    CONTENT="$2"
fi

COOKIE_FILE="${SCRIPT_PATH}/cookie/${QQ}.cookie.txt"
SKEY=$(cat "${COOKIE_FILE}" | grep skey | awk '{print $NF}')
GTK=$(node ${SCRIPT_PATH}/encode_g_tk.js "${SKEY}")

case "$3" in
post)
    post
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
    tid="$4"
    delete_by_tid "${tid}"
    ;;
*)
    list
    ;;
esac

exit
