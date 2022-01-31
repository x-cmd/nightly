

function jiter_after_tokenize(jobj, text,       _arr, _arrl, _i){
    _arrl = split( json_to_machine_friendly(text), _arr, "\n" )
    for (_i=1; _i<=_arrl; ++_i) {
        jiter( jobj, _arr[_i] )
    }
}

# Section: jiter
BEGIN{
    JITER_LEVEL = 1
    JITER_STACK[ 1 ] = ""   # keypath
}

function init_jiter(){
    JITER_FA_KEYPATH = ""
    JITER_STATE = T_ROOT
    JITER_LAST_KP = ""
    JITER_LEVEL = 1
    JITER_STACK[ 1 ] = ""
    JITER_CURLEN = 0

    JITER_LAST_KL = ""
}

function jiter( obj, item ){

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

# EndSection

# Section: jiter_

function init_jiter_(){
    JITER_FA_KEYPATH = ""
    JITER_STATE = T_ROOT
    JITER_LAST_KP = ""
    JITER_LEVEL = 1
    JITER_STACK[ 1 ] = ""
    JITER_CURLEN = 0

    JITER_LAST_KL = ""
}

function jiter_( item ){
    # efficiency defect 1%
    jiter( _, item )
}

# EndSection

# Section: jiter_print_exact
BEGIN{
    START_PRINT=0
    START_PRINT_S = 0
    START_PRINT_B = 0
}

# TODO: Find out where do we use it?
function _jiter_print_exact_setprint(kp, key){
    if (kp == key) {
        START_PRINT = 1
    }
}

function jiter_print_exact_after_tokenize(jobj, text, key,      _arr, _arrl, _i){
    _arrl = split( json_to_machine_friendly(text), _arr, "\n" )
    for (_i=1; _i<=_arrl; ++_i) {
        jiter_print_exact( jobj, _arr[_i], key )
    }
}


# TODO: Optimize. If key not match, then we SKIP.
function jiter_print_exact( obj, item, key ){
    if (START_PRINT == 2) {
        exit(0)
        return
    }

    if (START_PRINT == 1) {

        if (item ~ /^\[$/) {
            START_PRINT_S = START_PRINT_S + 1
        } else if (item ~ /^\]$/) {
            START_PRINT_S = START_PRINT_S - 1
        } else if (item ~ /^\{$/) {
            START_PRINT_B = START_PRINT_B + 1
        } else if (item ~ /^\}$/) {
            START_PRINT_B = START_PRINT_B - 1
        }

        if ( (START_PRINT_B == 0) && (START_PRINT_S == 0) ) {
            START_PRINT = 2
        }

        print item

        # if (START_PRINT == 2) {
        #     # print item
        # } else {
        #     print item
        # }

        return
    }

    if (item ~ /^[,:]*$/) {
        return
    } else if (item ~ /^[tfn"0-9+-]/) { #"
    # } else if (item !~ /^[\{\}\[\]]$/) {
        JITER_CURLEN = JITER_CURLEN + 1
        if ( JITER_STATE != T_DICT ) {
            # start printing
            # print JITER_FA_KEYPATH S "\"" JITER_CURLEN "\""  "\t" item
            if ( JITER_FA_KEYPATH S "\"" JITER_CURLEN "\"" == key ) {
                print item
                START_PRINT = 2
            }
        } else {
            if ( JITER_LAST_KP != "" ) {
                # start printing
                # print JITER_FA_KEYPATH S JITER_LAST_KP "\t" item
                if ( JITER_FA_KEYPATH S JITER_LAST_KP == key ) {
                    print item
                    START_PRINT = 2
                }
                JITER_LAST_KP = ""
            } else {
                JITER_LAST_KP = item
            }
        }
    } else if (item ~ /^\[$/) {
        JITER_CURLEN = JITER_CURLEN + 1
        obj[ JITER_FA_KEYPATH T_LEN ] = JITER_CURLEN
        if ( JITER_STATE != T_DICT ) {
            JITER_FA_KEYPATH = JITER_FA_KEYPATH S "\"" JITER_CURLEN "\""
        } else {
            JITER_FA_KEYPATH = JITER_FA_KEYPATH S JITER_LAST_KP
            JITER_LAST_KP = ""
        }

        JITER_STATE = T_LIST
        JITER_CURLEN = 0

        # start-printing
        if (JITER_FA_KEYPATH == key) {
            START_PRINT_S = START_PRINT_S + 1
            START_PRINT = 1
            print item
        }
        obj[ JITER_FA_KEYPATH ] = T_LIST

        JITER_STACK[ ++JITER_LEVEL ] = JITER_FA_KEYPATH
    } else if (item ~ /^\]$/) {
        obj[ JITER_FA_KEYPATH T_LEN ] = JITER_CURLEN

        JITER_LEVEL --

        JITER_FA_KEYPATH = JITER_STACK[ JITER_LEVEL ]
        JITER_STATE = obj[ JITER_FA_KEYPATH ]
        JITER_CURLEN = obj[ JITER_FA_KEYPATH T_LEN ]
    } else if (item ~ /^\{$/) {
        JITER_CURLEN = JITER_CURLEN + 1
        obj[ JITER_FA_KEYPATH T_LEN ] = JITER_CURLEN
        if ( JITER_STATE != T_DICT ) {
            JITER_FA_KEYPATH = JITER_FA_KEYPATH S "\"" JITER_CURLEN "\""
        } else {
            JITER_FA_KEYPATH = JITER_FA_KEYPATH S JITER_LAST_KP
            JITER_LAST_KP = ""
        }

        JITER_STATE = T_DICT
        JITER_CURLEN = 0

        # start-printing
        if (JITER_FA_KEYPATH == key) {
            START_PRINT_B = START_PRINT_B + 1
            START_PRINT = 1
            print item
        }
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
# EndSection
