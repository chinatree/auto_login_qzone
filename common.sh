#!/bin/bash
# author   : chinatree <chinatree2012@gmail.com>
# date     : 2013-01-04
# version  : 1.0.1

function get_color()
{
    case "$2" in
    BLOD)
        echo -ne "\033[1m"$1"\033[0m"
        ;;
    UNDERLINE)
        echo -ne "\033[4m"$1"\033[0m"
        ;;
    RED)
        echo -ne "\033[31m"$1"\033[0m"
        ;;
    GREEN)
        echo -ne "\033[32m"$1"\033[0m"
        ;;
    YELLOW)
        echo -ne "\033[33m"$1"\033[0m"
        ;;
    CYANBLUE)
        echo -ne "\033[36m"$1"\033[0m"
        ;;
    GOLDRED)
        echo -ne "\033[1;31m"$1"\033[0m"
        ;;
    GOLDGREEN)
        echo -ne "\033[1;32m"$1"\033[0m"
        ;;
    GOLDYELLOW)
        echo -ne "\033[1;33m"$1"\033[0m"
        ;;
    *)
        echo -ne "$1"
        ;;
    esac
}

function get_exit_code()
{
    if [ "$?" -ne 0 ];then
        echo "[`get_color " FAILED " RED`]"
        if [ "$2" -ne "1" ]; then
            exit "$1"
        fi
    else
        echo "[`get_color " OK " GREEN`]"
    fi
}
