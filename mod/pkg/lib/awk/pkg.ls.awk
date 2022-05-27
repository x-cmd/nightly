{
    installed_pkgarr[ ++ installed_pkgarrl ] = $0
}

END {
    for (i=1; i<=installed_pkgarrl; ++i) {
        PKG_NAME = installed_pkgarr[i]

        getline

        parse_pkg_meta_json( jobj, PKG_NAME, meta_json )
        parse_pkg_version_json( jobj, PKG_NAME, version_json )

        # calculate version

        # print

        if ($2 == $3) print $1 "\t" $2 TH_THEME_COLOR " (default)\033[0m"
        else print $1 "\t" $2
    }

}
