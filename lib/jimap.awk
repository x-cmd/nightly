
function jkp( ){
    return "\"" gsub(KSE{, ""})
}

# Section: jiter
BEGIN{
    JITER_LEVEL = 1
    JITER_STACK[ 1 ] = ""   # keypath
}

function init_jimap(){
    JITER_FA_KEYPATH = ""
    JITER_STATE = T_ROOT
    JITER_LAST_KP = ""
    JITER_LEVEL = 1
    JITER_STACK[ 1 ] = ""
    JITER_CURLEN = 0

    JITER_LAST_KL = ""

    # JTAR = JITER_TARGET
    JTAR_FA_KEYPATH = ""
    JTAR_STATE = T_ROOT
    JTAR_LAST_KP = ""
    JTAR_LEVEL = 0
    JTAR_CURLEN = 0

    JTAR_LAST_KL = ""

}

# Section: target parser

# example code
function jimap_target_keypath_eq( obj, item, jpath ){
    if ( JTAR_LEVEL == 0 ) {
        if ( jimap( item ) != true ) return
        if ( JITER_KA_KEYPATH != jpath ) return
    }
    ___jimap_target_parse( obj, item )
    if (JTAR_LEVEL == 0) return true
}

function jimap_target_eq_( item, keypath_regex ){
    return jimap_target_eq( _, item, keypath_regex)
}

function jimap_target_rmatch( obj, item, keypath_regex ){

    if ( JTAR_LEVEL == 0 ) {
        if ( jimap( item ) != true ) return
        match( JITER_FA_KEYPATH, keypath_regex )
        if ( RLENGTH <= 0 ) return
    }

    ___jimap_target_parse( obj, item )
    if (JTAR_LEVEL == 0) return true
}

function jimap_target_rmatch_( item, keypath_regex ){
    return jimap_target_rmatch( _, item, keypath_regex)
}

# {
#     if ( jimap_target_eq_( $0, jkp("*.height") ) == true ) {
#         # do something for _
#         # jstr( _ )
#         delete _
#     }
# }

function ___jimap_target_parse( obj, item ){
    if (item ~ /^[,:]*$/) {
        return
    }

    if (item ~ /^[tfn"0-9+-]/) #"
    # } else if (item !~ /^[\{\}\[\]]$/) {
    {
        JTAR_CURLEN = JTAR_CURLEN + 1
        if ( JTAR_STATE != T_DICT ) {
            obj[ JTAR_FA_KEYPATH S "\"" JTAR_CURLEN "\"" ] = item
        } else {
            if ( JTAR_LAST_KP != "" ) {
                JTAR_CURLEN = JTAR_CURLEN - 1
                obj[ JTAR_FA_KEYPATH S JTAR_LAST_KP ] = item
                JTAR_LAST_KP = ""
            } else {
                JTAR_LAST_KP = item
                obj[ JTAR_FA_KEYPATH T_KEY ] = obj[ JTAR_FA_KEYPATH T_KEY ] S item
            }
        }
    } else if (item ~ /^\[$/) {
        if ( JTAR_STATE != T_DICT ) {
            JTAR_CURLEN = JTAR_CURLEN + 1
            obj[ JTAR_FA_KEYPATH T_LEN ] = JTAR_CURLEN
            JTAR_FA_KEYPATH = JTAR_FA_KEYPATH S "\"" JTAR_CURLEN "\""
        } else {
            obj[ JTAR_FA_KEYPATH T_LEN ] = JTAR_CURLEN
            JTAR_FA_KEYPATH = JTAR_FA_KEYPATH S JTAR_LAST_KP
            JTAR_LAST_KP = ""
        }

        JTAR_STATE = T_LIST
        JTAR_CURLEN = 0

        obj[ JTAR_FA_KEYPATH ] = T_LIST

        obj[ ++JTAR_LEVEL ] = JTAR_FA_KEYPATH
    } else if (item ~ /^\]$/) {
        obj[ JTAR_FA_KEYPATH T_LEN ] = JTAR_CURLEN

        JTAR_LEVEL --

        JTAR_FA_KEYPATH = obj[ JTAR_LEVEL ]
        JTAR_STATE = obj[ JTAR_FA_KEYPATH ]
        JTAR_CURLEN = obj[ JTAR_FA_KEYPATH T_LEN ]
    } else if (item ~ /^\{$/) {
        if ( JTAR_STATE != T_DICT ) {
            JTAR_CURLEN = JTAR_CURLEN + 1
            obj[ JTAR_FA_KEYPATH T_LEN ] = JTAR_CURLEN
            JTAR_FA_KEYPATH = JTAR_FA_KEYPATH S "\"" JTAR_CURLEN "\""
        } else {
            obj[ JTAR_FA_KEYPATH T_LEN ] = JTAR_CURLEN
            JTAR_FA_KEYPATH = JTAR_FA_KEYPATH S JTAR_LAST_KP
            JTAR_LAST_KP = ""
        }

        JTAR_STATE = T_DICT
        JTAR_CURLEN = 0

        obj[ JTAR_FA_KEYPATH ] = T_DICT
        obj[ ++JTAR_LEVEL ] = JTAR_FA_KEYPATH
    } else if (item ~ /^\}$/) {
        obj[ JTAR_FA_KEYPATH T_LEN ] = JTAR_CURLEN

        JTAR_LEVEL --

        JTAR_FA_KEYPATH = obj[ JTAR_LEVEL ]
        JTAR_STATE = obj[ JTAR_FA_KEYPATH ]
        JTAR_CURLEN = obj[ JTAR_FA_KEYPATH T_LEN ]
    }
}
# EndSection

# Section: jimap core

function jimap( item ) {
    if (item ~ /^[,:]*$/) {
        return
    } else if (item ~ /^[tfn"0-9+-]/) #"
    # } else if (item !~ /^[\{\}\[\]]$/) {
    {
        JITER_CURLEN = JITER_CURLEN + 1
        if ( JITER_STATE == T_DICT ) {
            if ( JITER_LAST_KP != "" ) {
                JITER_CURLEN = JITER_CURLEN - 1
                JITER_LAST_KP = ""
            } else {
                JITER_LAST_KP = item
            }
        }
        return true
    } else if (item ~ /^\[$/) {
        if ( JITER_STATE != T_DICT ) {
            JITER_CURLEN = JITER_CURLEN + 1
            JITER_STACK[ JITER_FA_KEYPATH T_LEN ] = JITER_CURLEN
            JITER_FA_KEYPATH = JITER_FA_KEYPATH S "\"" JITER_CURLEN "\""
        } else {
            JITER_STACK[ JITER_FA_KEYPATH T_LEN ] = JITER_CURLEN
            JITER_FA_KEYPATH = JITER_FA_KEYPATH S JITER_LAST_KP
            JITER_LAST_KP = ""
        }

        JITER_STATE = T_LIST
        JITER_CURLEN = 0

        JITER_STACK[ JITER_FA_KEYPATH ] = T_LIST

        JITER_STACK[ ++JITER_LEVEL ] = JITER_FA_KEYPATH

        return true
    } else if (item ~ /^\]$/) {
        JITER_STACK[ JITER_FA_KEYPATH T_LEN ] = JITER_CURLEN

        JITER_LEVEL --

        JITER_FA_KEYPATH = JITER_STACK[ JITER_LEVEL ]
        JITER_STATE = JITER_STACK[ JITER_FA_KEYPATH ]
        JITER_CURLEN = JITER_STACK[ JITER_FA_KEYPATH T_LEN ]
    } else if (item ~ /^\{$/) {
        if ( JITER_STATE != T_DICT ) {
            JITER_CURLEN = JITER_CURLEN + 1
            JITER_STACK[ JITER_FA_KEYPATH T_LEN ] = JITER_CURLEN
            JITER_FA_KEYPATH = JITER_FA_KEYPATH S "\"" JITER_CURLEN "\""
        } else {
            JITER_STACK[ JITER_FA_KEYPATH T_LEN ] = JITER_CURLEN
            JITER_FA_KEYPATH = JITER_FA_KEYPATH S JITER_LAST_KP
            JITER_LAST_KP = ""
        }

        JITER_STATE = T_DICT
        JITER_CURLEN = 0

        JITER_STACK[ JITER_FA_KEYPATH ] = T_DICT

        JITER_STACK[ ++JITER_LEVEL ] = JITER_FA_KEYPATH

        return true
    } else if (item ~ /^\}$/) {
        JITER_STACK[ JITER_FA_KEYPATH T_LEN ] = JITER_CURLEN

        JITER_LEVEL --

        JITER_FA_KEYPATH = JITER_STACK[ JITER_LEVEL ]
        JITER_STATE = JITER_STACK[ JITER_FA_KEYPATH ]
        JITER_CURLEN = JITER_STACK[ JITER_FA_KEYPATH T_LEN ]
    }
}
# EndSection

# Section: target handler for print

# There is no handle_print, because if you want to format the output, pipe to another formatter
function handle_print1_eq(jpath){
    if (JTAR_LEVEL == 0){
        if ( jimap( item ) != true ) return
        if ( JITER_FA_KEYPATH != jpath) return
    }
    jimap_target_levelcal( item )
    printf("%s", item)
    if (JTAR_LEVEL == 0) {
        printf("\n")
        return true
    }
}

function handle_print0_eq(jpath){
    if (JTAR_LEVEL == 0){
        if ( jimap( item ) != true ) return
        if ( JITER_FA_KEYPATH != jpath) return
    }
    jimap_target_levelcal( item )
    printf("%s\n", item)
    if (JTAR_LEVEL == 0) {
        return true
    }
}

function jimap_target_levelcal( item ){
    if (item ~ /^[\[\{]$/) {
        JTAR_LEVEL += 1
    } else if (item ~ /^[\]\}]$/) {
        JTAR_LEVEL -= 1
    }
    return JTAR_LEVEL
}

# EndSection

