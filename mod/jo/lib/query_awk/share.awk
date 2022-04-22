
# a.b\\.c.d
# 'a."b.c".d.'"$1"

function selector_normalize_arr( selector, arr,     e, l ){
    # print "selector:" selector
    if ( selector ~ /^\./ ) selector = "1" selector
    gsub(/\\\\/, "\002", selector)
    gsub(/\\\./, "\003", selector)
    l = split(selector, arr, /\./)
    for (j=1; j<=l; ++j) {
        e = arr[j]
        gsub("\002", "\\\\", e)
        gsub("\003", ".", e)
        arr[j] = q( e )    # quote
    }

    return l
}

function selector_arr_join( sep, arrl, arr,     i, _ ){
    if (arrl == 0)  return ""
    # "1""LICENSE"
    for (i=1; i<=arrl; ++i) _ = _ sep arr[i]
    return _
}

function selector_normalize( selector,      arrl, arr){
    arrl = selector_normalize_arr( selector, arr )
    return selector_arr_join( S, arrl, arr )
}

# a."b.c".d => a.b\\.c.d
function handle_argument(argstr,       e ){
    argvl = split(argstr, argv, "\001")
    patarrl = selector_normalize_arr( argv[1], patarr )
    for (i=2; i<=argvl; ++i)    argv[ i-1 ] = selector_normalize( argv[i] );
    argvl = argvl - 1
}
