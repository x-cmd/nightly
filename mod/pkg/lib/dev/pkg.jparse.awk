BEGIN{
    K = "\007"
}

function pkg_jqparse_dict(jobj, kp,     token_arrl, token_arr,  idx,                 l, t, _kl ){
    jobj[ kp ] = "{"
    ++ idx
    _kl = SUBSEP
    while ( idx <= token_arrl ) {
        t = token_arr[ idx ]
        if (t == "}") {
            jobj[ kp L ] = l
            jobj[ kp K ] = _kl
            return idx + 1
        }
        t = uq( t )
        token_arr[ kp, ++ l ] = t
        _kl = _kl t SUBSEP
        idx = ___pkg_jqparse_value( jobj, kp SUBSEP t, token_arrl, token_arr, idx + 2 )
        if ( token_arr[ idx ] == "," )     idx ++
    }
    # return 11111111
}

function ___pkg_jqparse_value(jobj, kp,     token_arrl, token_arr,  idx,                     t ){
    t = token_arr[ idx ]
    if (t == "[")               return pkg_jqparse_list( jobj, kp, token_arrl, token_arr, idx )
    if (t == "{")               return pkg_jqparse_dict( jobj, kp, token_arrl, token_arr, idx )
    jobj[ kp ] = uq( t );       return idx + 1
}

function uq( str ){
    if (str ~ /^".*"$/) {
        str = substr( str, 2, length(str)-2 )
    }
    gsub( "/\\n/", "\n", str )
    gsub( "/\\t/", "\t", str )
    gsub( "/\\v/", "\v", str )
    gsub( "/\\b/", "\b", str )
    gsub( "/\\r/", "\r", str )
    return str
}

# Section: redundant
function pkg_jqparse_list(jobj, kp,     token_arrl, token_arr,  idx,                 l ){
    jobj[ kp ] = "["
    ++ idx
    while ( idx <= token_arrl ) {
        if (token_arr[ idx ] == "]") {
            jobj[ kp L ] = l
            return idx + 1
        }

        idx = ___pkg_jqparse_value( jobj, kp SUBSEP "\"" (++l) "\"", token_arrl, token_arr, idx )
        if ( token_arr[ idx ] == ",")     idx ++
    }
    # return 11111111
}
# EndSection

