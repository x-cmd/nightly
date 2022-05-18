function handle(            _final_version, _kp, _l, i, k, _version){
    _final_version = table_version( table, PKG_NAME)
    _final_version = juq(_final_version)
    if ( _final_version != "" ){
        print _final_version
    } else {
        _kp = pkg_kp( PKG_NAME, "meta", "rule" )
        _l = jobj[ _kp L ]
        for (i=1; i<=_l; ++i) {
            k = jobj[ _kp, i ]
            _version = jobj[ _kp SUBSEP k SUBSEP jqu("version")]
            if( _version != "" ) {
                pkg_add_table( "version", juq(_version), table, jqu(PKG_NAME) )
                pkg_define_version( table, PKG_NAME, jqu(PKG_NAME))
                handle()
                break
            }
        }
    }
}

END {
    handle()
}
