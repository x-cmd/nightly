
function jkp( ){
    return "\"" gsub(KSE{, ""})
}

# Section: jiter
BEGIN{
    JITER_LEVEL = 1
    JITER_STACK[ 1 ] = ""   # keypath
}

function init_jiter_capture(){
    JITER_FA_KEYPATH = ""
    JITER_STATE = T_ROOT
    JITER_LAST_KP = ""
    JITER_LEVEL = 1
    JITER_STACK[ 1 ] = ""
    JITER_CURLEN = 0

    JITER_LAST_KL = ""
}

function jiter_capture( obj, item ){

    if (item ~ /^[,:]*$/) {
        return
    } else if (item ~ /^[tfn"0-9+-]/) { #"
    # } else if (item !~ /^[\{\}\[\]]$/) {
        JITER_CURLEN = JITER_CURLEN + 1
        if ( JITER_STATE != T_DICT ) {
            obj[ JITER_FA_KEYPATH S "\"" JITER_CURLEN "\"" ] = item
        } else {
            if ( JITER_LAST_KP != "" ) {
                JITER_CURLEN = JITER_CURLEN - 1
                obj[ JITER_FA_KEYPATH S JITER_LAST_KP ] = item
                JITER_LAST_KP = ""
            } else {
                JITER_LAST_KP = item
                obj[ JITER_FA_KEYPATH T_KEY ] = obj[ JITER_FA_KEYPATH T_KEY ] S item
            }
        }
    } else if (item ~ /^\[$/) {
        if ( JITER_STATE != T_DICT ) {
            JITER_CURLEN = JITER_CURLEN + 1
            obj[ JITER_FA_KEYPATH T_LEN ] = JITER_CURLEN
            JITER_FA_KEYPATH = JITER_FA_KEYPATH S "\"" JITER_CURLEN "\""
        } else {
            obj[ JITER_FA_KEYPATH T_LEN ] = JITER_CURLEN
            JITER_FA_KEYPATH = JITER_FA_KEYPATH S JITER_LAST_KP
            JITER_LAST_KP = ""
        }

        JITER_STATE = T_LIST
        JITER_CURLEN = 0

        obj[ JITER_FA_KEYPATH ] = T_LIST

        JITER_STACK[ ++JITER_LEVEL ] = JITER_FA_KEYPATH
    } else if (item ~ /^\]$/) {
        obj[ JITER_FA_KEYPATH T_LEN ] = JITER_CURLEN

        JITER_LEVEL --

        JITER_FA_KEYPATH = JITER_STACK[ JITER_LEVEL ]
        JITER_STATE = obj[ JITER_FA_KEYPATH ]
        JITER_CURLEN = obj[ JITER_FA_KEYPATH T_LEN ]
    } else if (item ~ /^\{$/) {
        if ( JITER_STATE != T_DICT ) {
            JITER_CURLEN = JITER_CURLEN + 1
            obj[ JITER_FA_KEYPATH T_LEN ] = JITER_CURLEN
            JITER_FA_KEYPATH = JITER_FA_KEYPATH S "\"" JITER_CURLEN "\""
        } else {
            obj[ JITER_FA_KEYPATH T_LEN ] = JITER_CURLEN
            JITER_FA_KEYPATH = JITER_FA_KEYPATH S JITER_LAST_KP
            JITER_LAST_KP = ""
        }

        JITER_STATE = T_DICT
        JITER_CURLEN = 0

        obj[ JITER_FA_KEYPATH ] = T_DICT

        JITER_STACK[ ++JITER_LEVEL ] = JITER_FA_KEYPATH
    } else if (item ~ /^\}$/) {
        obj[ JITER_FA_KEYPATH T_LEN ] = JITER_CURLEN

        JITER_LEVEL --

        JITER_FA_KEYPATH = JITER_STACK[ JITER_LEVEL ]
        JITER_STATE = obj[ JITER_FA_KEYPATH ]
        JITER_CURLEN = obj[ JITER_FA_KEYPATH T_LEN ]
    }
}


BEGIN{
    jiter_capture_setup( json_kp("work", 1, "handle", "a") )
}

{
    if ( jiter_capture( token, json_kp("work", 1, "handle", "a") ) ){
        return
    }

    jiter_capture_get("a" KSEP "b")
    jiter_capture_get_raw("a" KSEP "b")

}



# Section: jiter other extract design

BEGIN{

    if (false == jiter_handle_when_kp_eq(token, json_kp("work", 1, "handle", "a") )){
        return
    }

    if (false == jiter_handle_when_kp_partof(token, json_kp("work", 1, "handle", "a") )){
        return
    }

    if (false == jiter_handle_when_kp_hasprefix(token, json_kp("work", 1, "handle", "a") )){
        return
    }

    JITER_KP = work
    JITER_KEY = 1
    JITER_KEY = 1
    JITER_VAL = 2

    if ( true == json_kp_has( JITER_KEY, json_kp(1, "handle", "a", "1", "work") ) ) {

    }

    if ( true == json_kp_has( JITER_KEY, json_kp(1, "handle", "a", "1", "work") ) ) {

    }

}





# EndSection
