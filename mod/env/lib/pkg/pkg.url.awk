NR==1 {
    pkg_name = $0
}

NR==2 {
    meta = $0
}

NR==3 {
    version = $0
}

END {
    parse_pkg_meta_json( jobj, pkg_name, meta )
    parse_pkg_version_json( jobj, pkg_name, version )

    pkg_init_table( jobj, table, jqu(pkg_name), pkg_name, "v8.3.2", "linux-arm64")

    print "get-exe:\t" jobj[ pkg_kp( pkg_name, "meta", "rule", "v*/win-*", "dot_exe" ) ]

    print "url_default:\t" pkg_kp( pkg_name, "meta", "rule", "v*/win-*", "dot_exe" )

    print "--------"
    print table[ pkg_kp( pkg_name, "sb_repo" ) ]

    str = table[ pkg_kp( pkg_name, "sb_gh" ) ]

    print "---" pkg_eval_str( str, table, "nmap" )

}

