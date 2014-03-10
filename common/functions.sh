#!/bin/bash
# Author  : chinatree <chinatree2012@gmail.com>
# Date    : 2014-02-11
# Version : 1.3

get_color()
{
    case "${2:-NONE}" in
    BOLD)
        echo -ne "\033[1m"$1"\033[0m"
        ;;
    UNDERLINE)
        echo -ne "\033[4m"$1"\033[0m"
        ;;
    RED)
        echo -ne "\033[0;31;40m"$1"\033[0m"
        ;;
    GREEN)
        echo -ne "\033[0;32;40m"$1"\033[0m"
        ;;
    BROWN)
        echo -ne "\033[33m"$1"\033[0m"
        ;;
    PURPLE)
        echo -ne "\033[0;35;40m"$1"\033[0m"
        ;;
    PEACH)
        echo -ne "\033[1;31;40m"$1"\033[0m"
        ;;
    YELLOW)
        echo -ne "\033[1;33;40m"$1"\033[0m"
        ;;
    CYANBLUE)
        echo -ne "\033[36m"$1"\033[0m"
        ;;
    PORTMPT)
        echo -ne "\033[5;37;44m"$1"\033[0m"
        ;;
    *)
        echo -ne "$1"
        ;;
    esac
}

get_fixed_width()
{
    local str="${1:-NONE}"
    local length="${2:-0}"
    local isEnter="${3:-NONE}"
    case "${length:-NONE}" in
    12)
        printf "%-12s" "${str}"
        ;;
    20)
        printf "%-20s" "${str}"
        ;;
    50)
        printf "%-50s" "${str}"
        ;;
    66)
        printf "%-66s" "${str}"
        ;;
    88)
        printf "%-88s" "${str}"
        ;;
    *)
        printf "%${length}s" "${str}"
        ;;
    esac
    if [ "${isEnter}" = "Y" ];
    then
        echo -ne "\n";
    fi
}

get_exit_code()
{
    if [ "${1:-1}" -ne 0 ];then
        echo "[`get_color " FAILED " RED`]"
        if [ "${2:-1}" -ne 0 ]; then
            exit "$1"
        else
            return
        fi
    else
        echo "[`get_color " OK " GREEN`]"
    fi
}