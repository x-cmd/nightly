
# Section: calculate string
function pkg_eval_str( str, pkg_name, version, osarch,              _const ){
    pkg_const_init( _const, pkg_name, version, osarch )
    pkg_const_load( _const, pkg_name, version, osarch )
    pkg_eval_str_from_const( str, _const )
}

function pkg_eval_str_from_const( str, const,    _newstr ){
    while ( match( str, "\%\{[^\}]\}\%" ) ) {
        p = substr( str, RSTART, RLENGTH )
        t = const[p]
        if ( t == "" )  {
            printf("Unknown pattern[%s] from str: %s", t, str)
            exit(1)
        }
        _newstr = substr( str, 1, RSTART-1 ) t substr( str, RSTART + RLENGTH )
        if (_newstr == str)  {
            printf("Logic error. Target not changed.")
            exit(1)
        }
        str = _newstr
    }
    return str
}

function pkg_const_init( const, pkg_name, version, osarch,            l, i ){
    if (pkg_name != "")     l = pkg_const_arr_push( const, "%{pkg_name}", pkg_name )
    if (version != "")      l = pkg_const_arr_push( const, "%{version}", version )
    if (osarch != "")       l = pkg_const_arr_push( const, "%{osarch}", osarch )

    l = pkg_const_arr_push( const, "%{sb_branch}",  "main" )
    l = pkg_const_arr_push( const, "%{sb_gt}",      "https://gitee.com/static-build/%{pkg_name}/raw/%{sb_branch}/bin" )
    l = pkg_const_arr_push( const, "%{sb_gh}",      "https://raw.githubusercontent.com/static-build/%{pkg_name}/%{sb_branch}/bin" )

    return l
}


function pkg_const_load( const, jobj, pkg_name, version, osarch,            i, l, p ){
    # load const string from meta.const
    pkg_const_load_( const, jobj,         qu(pkg_name) SUBSEP qu("meta") SUBSEP qu("const") )

    # load const string from meta.osarch.const
    pkg_const_load_( const, jobj,         qu(pkg_name) SUBSEP qu("meta") SUBSEP qu("os-arch") SUBSEP qu(osarch) SUBSEP qu("const") )

    # load const string from version.osarch.const
    pkg_const_load_( const, jobj,         qu(pkg_name) SUBSEP qu("version") SUBSEP qu(version) SUBSEP qu("const") )

    # load const string from version.osarch.const
    pkg_const_load_( const, jobj,         qu(pkg_name) SUBSEP qu("version") SUBSEP qu(version) SUBSEP qu(osarch) SUBSEP qu("const") )
}

function pkg_const_load_( const, jobj, kp,       l, k, i ){
    l = jobj[ kp L ]
    for (i=1; i<=l; ++i) {
        k = jobj[ kp, i ]
        pkg_const_arr_push( const, "%{" k "}", jobj[ kp, k ] )
    }
}

function pkg_const_arr_push( const, k, v,       l ) {
    l = const[ L ]
    const[ , ++l ] = k
    const[ k ] = v
    return const[ L ] = l
}

# EndSection

# Section: raw attribute

function qu( s ){
    return "\"" s "\""
}


function pkg___attr( jobj, pkg_name, version, attr,  r){
    if (version != "") {
        r = jobj[ qu(pkg_name), qu("version"), qu(version), attr  ]
    }
    return r || jobj[ qu(pkg_name), qu("meta"), attr ]
}

function pkg_homepage( jobj, pkg_name, version ){
    return pkg___attr( jobj, pkg_name, version, qu("homepage") )
}

function pkg_license( jobj, pkg_name, version ){
    return pkg___attr( jobj, pkg_name, version, qu("license") )
}

function pkg_url_default( jobj, pkg_name, version ){
    return pkg___attr( jobj, pkg_name, version, qu("url") SUBSEP qu("_") )
}

function pkg_url_cn( jobj, pkg_name, version ){
    return pkg___attr( jobj, pkg_name, version, qu("url") SUBSEP qu("cn") )
}

# EndSection

# Section: parsing

function parse_pkg_jqparse( str, jobj, kp,       arrl, arr ){
    arrl = split(str, arr, "\t")
    return jqparse_dict( jobj, kp,   arrl, arr )
}

function parse_pkg_meta_json(jobj, pkg_name, meta_json) {
    return parse_pkg_jqparse( meta_json,     jobj, qu(pkg_name) SUBSEP qu("meta") )
}

function parse_pkg_version_json(jobj, pkg_name, meta_json) {
    return parse_pkg_jqparse( version_json,  jobj, qu(pkg_name) SUBSEP qu("version") )
}

# EndSection
