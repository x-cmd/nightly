# Section: jiparse
BEGIN{
    JITER_LEVEL = 1
    JITER_STACK[ 1 ] = ""   #  keypath
}

# Section: EqArr
function jiter_eqarr_print( obj, item, arrl, arr, sep1, sep2 ){
    if ( JITER_SKIP_LEVEL == 0) {
        if ( jiter_eqarr( item, arrl, arr ) != true ) return false
        jiter_save( JITER_STACK )
        jiter_init()
    }

    jiter_skip( item )
    printf("%s" sep1, item)
    if ( JITER_SKIP_LEVEL != 0 ) return false
    if ( JITER_CURLEN == 0 ) jiter( item, JITER_STACK )  # Roll back
    printf(sep2)
    return true
}

function jiter_eqarr_parse( obj, item, arrl, arr ){
    if ( JITER_EQARR_PARSE == 0) {
        if ( jiter_eqarr( item, arrl, arr ) != true ) return false
        jiter_save( JITER_STACK )
        jiter_init()
        JITER_EQARR_PARSE = 1
    }

    jiparse( obj, item )
    if (JITER_LEVEL > 1) return false
    JITER_EQARR_PARSE = 0
    jiter_load( JITER_STACK )
    if ( JITER_CURLEN != 0 ) jiter_eqarr( item, arrl, arr )   # Roll back
    return true
}

function jiter_eqarr( item, arrl, arr,    _ret ){
    if ( JITER_SKIP_LEVEL == 0 ) {
        _ret = jiter_for_current_key( item, JITER_STACK )
        if ( _ret == "" ) return false
        if ( arr[ JITER_LEVEL ] == _ret ) {
            if ( JITER_LEVEL == arrl ) {
                return true
            }
            return false
        }
    }
    jiter_skip( item )
    if ( JITER_SKIP_LEVEL == 0 ) {
        if ( JITER_CURLEN == 0 ) {
            jiter_for_current_key( item, JITER_STACK )  # Roll back
        }
    }
    return false
}
# EndSection

# Section: jiter_for_current_key
function jiter_for_current_key( item, stack,  _res ) {
    if (item ~ /^[,:]*$/) return
    if (item ~ /^[tfn"0-9+-]/) #"   # (item !~ /^[\{\}\[\]]$/) {
    {
        if ( JITER_LAST_KP != "" ) {
            _res = JITER_LAST_KP
            JITER_LAST_KP = ""
            return JITER_LAST_KP
        }
        JITER_CURLEN = JITER_CURLEN + 1
        if ( JITER_STATE != T_DICT ) {
            return "\"" JITER_CURLEN "\""
        }
        JITER_LAST_KP = item
    } else if (item ~ /^[\[\{]$/) { # }
        if ( JITER_STATE != T_DICT ) {
            JITER_CURLEN = JITER_CURLEN + 1
            stack[ JITER_LEVEL T_LEN ] = JITER_CURLEN
            _res = "\"" JITER_CURLEN "\""
        } else {
            stack[ JITER_LEVEL T_LEN ] = JITER_CURLEN
            _res = JITER_LAST_KP
            JITER_LAST_KP = ""
        }
        JITER_STATE = item
        JITER_CURLEN = 0

        stack[ ++JITER_LEVEL ] = item
        return _res
    } else {
        JITER_STATE = stack[ -- JITER_LEVEL ]
        JITER_CURLEN = stack[ JITER_LEVEL T_LEN ]
    }
    return ""
}

# EndSection

# Section: target handler for print
# There is no jiter_handle_print, because if you want to format the output, pipe to another formatter
function jiter_print_rmatch( item, keypath, sep1, sep2,   _ret ){
    if (JITER_SKIP_LEVEL == 0){
        _ret = jiter( item, JITER_STACK )
        if ( _ret == "" ) return false
        if ( match(_ret, keypath) == 0 ) return false
    }

    jiter_skip( item )
    printf("%s" sep1, item)
    if ( JITER_SKIP_LEVEL != 0 ) return false
    if ( JITER_CURLEN == 0 ) jiter( item, JITER_STACK )  # Roll back
    printf(sep2)
    return true
}

function jiter_target_rmatch_val( item, keypath_regex ){
    _ret = jiter( item, JITER_STACK )
    if ( _ret == "" ) return
    if ( match(_ret, keypath) == 0 ) return
    return item
}

function jiter_target_rmatch( obj, item, keypath_regex ){
    if ( JITER_TARGET_RMATCH_SWITCH == 0 ) {
        _ret = jiter( item, JITER_STACK )
        if ( _ret == "" ) return false
        if ( match(_ret, keypath) == 0 ) return false

        jiter_save( JITER_SAVE )
        jiter_init()
        JITER_TARGET_RMATCH_SWITCH = 1
    }
    jiparse( obj, item )
    if (JITER_LEVEL == 0) {
        JITER_TARGET_RMATCH_SWITCH = 0
        jiter_load( JITER_SAVE )
        if ( JITER_CURLEN == 0 ) {
            # Roll back
            jiter( item, JITER_STACK )
        }
        return true
    }
    return false
}
# EndSection

# Section: leaf and flat
function jileaf( obj, item, sep1, sep2, _kp ){
    _kp = jiter( item, obj )
    if ( item !~ /^[\[\{}]]$/ ) {
        printf("%s%s%s%s", _kp, sep1, item, sep2)
    }
}

function jiflat( obj, item, sep1, sep2, _kp ){
    _kp = jiter( item, obj )
    if ( item !~ /^[\[\{}]]$/ ) {
        printf("%s%s%s%s", _kp, sep1, item, sep2)
    }
}
# EndSection

# Section: jiter core and jiter_skip
function jiter_skip( item ){
    if (item ~ /^[\[\{]$/) {
        JITER_SKIP_LEVEL += 1
    } else if (item ~ /^[\]\}]$/) {
        JITER_SKIP_LEVEL -= 1
    }
    return JITER_SKIP_LEVEL
}

function jiter( item, stack,  _res ) {
    if (item ~ /^[,:]*$/) return
    if (item ~ /^[tfn"0-9+-]/) #"   # (item !~ /^[\{\}\[\]]$/) {
    {
        if ( JITER_LAST_KP != "" ) {
            _res = JITER_FA_KEYPATH S JITER_LAST_KP
            JITER_LAST_KP = ""
            return _res
        }
        JITER_CURLEN = JITER_CURLEN + 1
        if ( JITER_STATE != T_DICT ) {
            return JITER_FA_KEYPATH S "\"" JITER_CURLEN "\""
        }
        JITER_LAST_KP = item
        # return JITER_FA_KEYPATH S JITER_CURLEN
    } else if (item ~ /^[\[\{]$/) { # }
        if ( JITER_STATE != T_DICT ) {
            JITER_CURLEN = JITER_CURLEN + 1
            stack[ JITER_FA_KEYPATH T_LEN ] = JITER_CURLEN
            JITER_FA_KEYPATH = JITER_FA_KEYPATH S "\"" JITER_CURLEN "\""
        } else {
            stack[ JITER_FA_KEYPATH T_LEN ] = JITER_CURLEN
            JITER_FA_KEYPATH = JITER_FA_KEYPATH S JITER_LAST_KP
            JITER_LAST_KP = ""
        }
        JITER_STATE = item
        JITER_CURLEN = 0

        stack[ JITER_FA_KEYPATH ] = item
        stack[ ++JITER_LEVEL ] = JITER_FA_KEYPATH
        return JITER_FA_KEYPATH
    } else {
        stack[ JITER_FA_KEYPATH T_LEN ] = JITER_CURLEN

        JITER_FA_KEYPATH = stack[ -- JITER_LEVEL ]
        JITER_STATE = stack[ JITER_FA_KEYPATH ]
        JITER_CURLEN = stack[ JITER_FA_KEYPATH T_LEN ]
    }
    return ""
}
# EndSection

