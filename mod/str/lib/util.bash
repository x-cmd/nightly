
# Section: repr and replace

# TODO: rename to quote
___x_cmd_str_repr(){
    # echo "\"$(echo "$1" | sed s/\"/\\\\\"/g)\""
    # echo "\"${1//\"/\\\\\"}\""
    # echo "\"${1//\"/\\\"}\""
    printf '"%s"' "${1//\"/\\\"}"
}


# case "$___X_CMD_CUR_SHELL" in
#     bash|zsh|ksh|ash)
# ___x_cmd____x_cmd_str_replace(){
#     local pat="${2//\*/\\*}"
#     return "${1/"$pat"/"$3"}"
# }

# ___x_cmd____x_cmd_str_replaceall(){
#     local pat="${2//\*/\\*}"
#     return "${1//"$2"/"$3"}"
# }
#     ;;
#     *)
# ___x_cmd____x_cmd_str_replace(){
#     printf "%s" "$1" | awk -v pat="$2" -v target="$3" -v IFS="" '
# END{
#     sub(pat, target, $0)
#     print $0
# }
# '
# }

# ___x_cmd____x_cmd_str_replaceall(){
#     printf "%s" "$1" | awk -v pat="$2" -v target="$3" -v IFS="" '
# END{
#     gsub(pat, target, $0)
#     print $0
# }
# '
# }
#     ;;
# esac


___x_cmd_str_replace(){
    printf "%s" "${${1:?Original string}/"${2:?Source substring}"/${3:?Target string}}"
}

___x_cmd_str_replace_all(){
    printf "%s" "${${1:?Original string}//"${2:?Source substring}"/${3:?Target string}}"
}

# TODO: Not for ash. Please provide compatible version
___x_cmd_str_replace_n(){
    local org="${1:?Original string}"
    local src="${2:?Source substring}"
    local num="${3:?Number}"
    local tgt="${4:?Target string}"
    local SUBSEP=$'\034' i
    for i in $(seq $(( num -1 )) ); do
        org="${org/"$src"/$SUBSEP}"
    done
    org="${org/"$src"/$tgt}"
    echo "${org//$SUBSEP/$src}"
}

## EndSection
