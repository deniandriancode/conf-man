#!/usr/bin/env bash

# Load utils library
source ./utils.sh

operation=''
arg=''

while getopts "o:d:b:c:Vh?" opt; do
    case "$opt" in
        o)
            arg=${OPTARG}
            operation="open_config"
            ;;
        d)
            arg=${OPTARG}
            operation="delete_config"
            ;;
        b)
            arg=${OPTARG}
            operation="backup_config"
            ;;
        c)
            elem=$(eval echo \${$(($OPTIND))})
            arg=(${OPTARG} ${elem})
            operation="copy_config"
            ;;
        V)
            operation="version_info"
            ;;
        ?|h)
            operation="help_prompt"
            ;;
    esac
done

echo "${arg[@]}"
$operation "${arg[@]}"
