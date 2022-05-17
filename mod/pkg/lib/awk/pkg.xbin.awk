

# Provide

function code( funcname, binpath ){
    print "___x_cmd_" funcname "(){"
    print "  " binpath "\"$@\""
    print "}"
}

END {
    prefix = jqu(PKG_NAME) SUBSEP jqu("xbin")

    if ( "{" != table[ prefix ] ) {
        print code( PKG_NAME, table[ prefix ] ) # DO Not unquote
        exit(0)
    }

    print "Not implemented YET" >"/dev/stderr"

    exit(1)

    # TODO: Will Implemente in the future
    l = table[ prefix L ]
    for (i=1; i<=l; ++i) {
        k = table[ prefix, i ]
        print k
        v = table[ prfeix, k ]

        if ( "{" != v ) {
            print table_eval(table, PKG_NAME, v )
            continue
        }
        # TODO: will introduce setpath
    }

}
