

END {
    result = jobj[ prefix, k, jqu("version") ]
    if (result == "") {
        exit(1)
    } else {
        print PKG_RAWPATH "/" PKG_NAME "/" VERSION_REALNAME "/.x-cmd/" juq(result)
        exit(0)
    }
}


# NR==1 {
#     meta_json = $0
# }

# NR==2 {
#     version_json = $0
# }

# END {
#     parse_pkg_meta_json( jobj, PKG_NAME, meta_json )
#     parse_pkg_version_json( jobj, PKG_NAME, version_json )

#     pkg_init_table( jobj, table, jqu(PKG_NAME), PKG_NAME, VERSION_NAME, OSARCH )


#     prefix = pkg_kp( PKG_NAME, "version")
#     l = jobj[ prefix L ]
#     for (i=1; i<=l; ++i) {
#         k = jobj[ prefix, i ]
#         release_date = jobj[ prefix, k, jqu("release_date") ]
#         description = jobj[ prefix, k, jqu("desc") ]
#     }

# }

