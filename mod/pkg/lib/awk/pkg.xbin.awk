

# Provide

function code( funcname, binpath ){
    gsub("/", "_", funcname)
    print "___x_cmd_" funcname "(){"
    print "  " INSTALL_PATH "/" PKG_NAME "/" binpath " \"$@\""
    print "}"
}

END {
    prefix = jqu(PKG_NAME) SUBSEP jqu("xbin")

    if ( "{" != table[ prefix ] ) {
        print code( PKG_NAME "_xbin", table_eval(table, PKG_NAME, table[ prefix ] ) ) # DO Not unquote
        exit(0)
    }

    # print "Not implemented YET" >"/dev/stderr"

    # exit(1)

    # TODO: Will Implemente in the future
    l = table[ prefix L ]
    for (i=1; i<=l; ++i) {

        k = table[ prefix, i ]
        v = table[ prefix, k ]

        if ( "{" != v ) {
            print code( PKG_NAME "_" juq(k), table_eval(table, PKG_NAME, v ) )
            continue
        }
        # TODO: will introduce setpath
    }

}
