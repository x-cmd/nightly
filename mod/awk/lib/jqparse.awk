BEGIN{
    L = "\003"
}

function jqparse_str( obj, kp, token_str, sep,     _arr, _arrl ) {
    _arrl = json_split2tokenarr( _arr, token_str )
    # for (i=1; i<=_arrl; ++i) print _arr[i]
    return jqparse( obj, kp, _arrl, _arr )
}

function jqparse(obj, kp,      token_arrl, token_arr,                                   i, l ){
    i = 1
    while (i <= token_arrl) {
        if (token_arr[i] == "") { i++; continue; }
        i = ___jqparse_value( obj, kp SUBSEP "\"" ++l "\"",    token_arrl, token_arr, i )
    }
    obj[ kp L ] = l
}

function ___jqparse_value(obj, kp,     token_arrl, token_arr,  idx,                     t ){
    t = token_arr[ idx ]
    if (t == "[")       return jqparse_list( obj, kp, token_arrl, token_arr, idx )
    if (t == "{")       return jqparse_dict( obj, kp, token_arrl, token_arr, idx )
    obj[ kp ] = t;      return idx + 1
}

function jqparse_list(obj, kp,     token_arrl, token_arr,  idx,                 l ){
    obj[ kp ] = "["
    ++ idx
    while ( idx <= token_arrl ) {
        if (token_arr[ idx ] == "]") {
            obj[ kp L ] = l
            return idx + 1
        }

        idx = ___jqparse_value( obj, kp SUBSEP "\"" (++l) "\"", token_arrl, token_arr, idx )
        if ( token_arr[ idx ] == ",")     idx ++
    }
    # return 11111111
}

function jqparse_dict(obj, kp,     token_arrl, token_arr,  idx,                 l, t){
    obj[ kp ] = "{"
    ++ idx
    while ( idx <= token_arrl ) {
        t = token_arr[ idx ]
        if (t == "}") {
            obj[ kp L ] = l
            return idx + 1
        }
        token_arr[ kp, ++ l ] = t
        idx = ___jqparse_value( obj, kp SUBSEP t, token_arrl, token_arr, idx + 2 )
        if ( token_arr[ idx ] == "," )     idx ++
    }
    # return 11111111
}
