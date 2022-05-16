

END {
    prefix = jqu(PKG_NAME) SUBSEP jqu("url") SUBSEP jqu( NET_REGION )

    if ( "[" != table[ prefix ] ) {
        printf juq( table[ prefix ] )
    } else {
        l = table[ prefix L ]
        for (i=1; i<=l; ++i) {
            print juq( table[ prefix, i ] )
        }
    }
}


