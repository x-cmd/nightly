
function handle( qpat ){
    varname = qpat
    gsub(".", SUBSEP, qpat)
    gsub(".", "_", varname)
    print varname "=" jobj[ PKG_NAME, qpat ]
}

NR>2 {
    handle( $0 )
}

END {
    query_arrl = split(QUERY, query_arr, ",")
    for (i=1; i<=query_arrl; ++i) {
        handle ( query_arr[ i ] )
    }
}
