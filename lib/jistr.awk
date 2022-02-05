
# jistr_indent
# state
function jistr(token){
    return 0
}

# cat a.json | awk '{ jistr( $0 ); }'

# cat a.json | awk '{ print jtokenize($0) }' | awk '{ print jistr( $0 ); }'
