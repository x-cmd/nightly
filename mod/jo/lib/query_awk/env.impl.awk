# a."b.c".d => a.b\\.c.d
function handle_argument(argstr,       e ){
    argvl = split(argstr, argv, "\001")
    patarrl = selector_normalize_generic( argv[1], patarr )
    for (i=2; i<=argvl; ++i) {
        e =  accessor_normalize( argv[i] )
        if (e ~/^[A-Za-z0-9_]+=/) {
            varname[ i - 1 ] = substr( e, 1, RLENGTH-1 )
            argv[ i-1 ] = substr( e, RLENGTH+1 )
        } else {
            if (! match(e, /[A-Za-z0-9_]+$/) ){
                print "Cannot reason out a valid variable name from: " e >"/dev/stderr"
                exit(1)
            }
            varname[ i - 1 ] = substr( e, RSTART )
            argv[ i - 1 ] = e
        }

    }
    argvl = argvl - 1
}

function handle_output(idx, value) {
    if ( idx == 1) {
        count += 1
        if (count > 1)  print "\n"
    }
    print varname[ idx ] "=" value ";"
}

END{
    print "\n"
}
