# Section: jiparse
BEGIN{
    JITER_LEVEL = 1
    JITER_STACK[ 1 ] = ""   #  keypath
}

# Using JiCore With EqArr
function jiter_target_eqarr( obj, item, arrl, arr,     _ret ){
    if ( JTAR_LEVEL == 0 ) {
        _ret = jiter( item, JITER_STACK )
        # print "jiter \t " item "\t|" _ret "|\t|" keypath "|"
        if ( _ret == "" ) return false
        if ( _ret != keypath) return false
    }
    ___jiter_target_parse( obj, item )
    if (JTAR_LEVEL == 0) return true
    return false
}

# Section: Using JiCore With RMatchArr
function jiter_target_rmatcharr( obj, item, arrl, arr    _ret ){
    if ( JTAR_LEVEL == 0 ) {
        _ret = jiter( item, JITER_STACK )
        # print "jiter \t " item "\t|" _ret "|\t|" keypath "|"
        if ( _ret == "" ) return false
        if ( _ret != keypath) return false
    }
    ___jiter_target_parse( obj, item )
    if (JTAR_LEVEL == 0) return true
    return false
}

# EndSection

# Section: target parser
function jiter_target_rmatch( obj, item, keypath_regex ){
    if ( JTAR_LEVEL == 0 ) {
        _ret = jiter( item, JITER_STACK )
        if ( _ret == "" ) return false
        match( _ret, keypath_regex )
        if ( RLENGTH <= 0 ) return false
        jiter_save( JITER_SAVE )
    }
    jiparse( obj, item )
    if (JTAR_LEVEL == 0) {
        jiter_load( JITER_SAVE )
        return true
    }
    return false
}

function jiter_target_rmatch_( item, keypath_regex ){
    return jiter_target_rmatch( _, item, keypath_regex)
}
# EndSection

# Section: target handler for print
# There is no jiter_handle_print, because if you want to format the output, pipe to another formatter
function jiter_print1_rmatch( item, keypath,    _ret ){
    if (JITER_SKIP_LEVEL == 0){
        _ret = jiter( item, JITER_STACK )
        if ( _ret == "" ) return false
        if ( match(_ret, keypath) == 0 ) return false
    }
    jiter_skip( item )
    printf("%s", item)
    if ( JITER_SKIP_LEVEL == 0 ) {
        if ( JITER_CURLEN == 0 ) {
            # Roll back
            jiter( item, JITER_STACK )
        }
        printf("\n")
        return true
    }
    return false
}

function jiter_print0_rmatch( item, keypath ){
    if (JITER_SKIP_LEVEL == 0){
        _ret = jiter( item, JITER_STACK )
        if ( _ret == "" ) return false
        if ( match(_ret, keypath) == 0 ) return false
    }
    jiter_skip( item )
    printf("%s\n", item)
    if ( JITER_SKIP_LEVEL == 0 ) {
        if ( JITER_CURLEN == 0 ) {
            # Roll back
            jiter( item, JITER_STACK )
        }
        return true
    }
    return false
}

function jiter_skip( item ){
    if (item ~ /^[\[\{]$/) {
        JITER_SKIP_LEVEL += 1
    } else if (item ~ /^[\]\}]$/) {
        JITER_SKIP_LEVEL -= 1
    }
    return JITER_SKIP_LEVEL
}

# EndSection

# Section: jiter core and leaf and flat
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

