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


    prefix = pkg_kp( pkg_name, "version")
    l = jobj[ prefix L ]
    for (i=1; i<=l; ++i) {
        k = jobj[ prefix, i ]
        release_date = jobj[ prefix, k, jqu("release_date") ]
        description = jobj[ prefix, k, jqu("desc") ]
    }

}

