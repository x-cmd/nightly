
# Section: jiparse after tokenized
function jiparse_after_tokenize( obj, text,       _arr, _arrl, i){
    _arrl = json_split2tokenarr( _arr, text )
    for (i=1; i<=_arrl; ++i) {
        jiparse( obj, _arr[i] )
    }
}
# EndSection

# Section: jiparse
function jiparse( obj, item ){
    if (item ~ /^[,:]?$/) return
    if (item ~ /^[tfn"0-9+-]/)   #"        # (item !~ /^[\{\}\[\]]$/)
    {
        if ( JITER_LAST_KP != "" ) {
            obj[ JITER_FA_KEYPATH S JITER_LAST_KP ] = item
            JITER_LAST_KP = ""
        } else {
            JITER_CURLEN = JITER_CURLEN + 1
            if (JITER_STATE != T_DICT) {
                obj[ JITER_FA_KEYPATH S "\"" JITER_CURLEN "\"" ] = item
            } else {
                JITER_LAST_KP = item
                obj[ JITER_FA_KEYPATH T_KEY ] = obj[ JITER_FA_KEYPATH T_KEY ] S item
            }
        }
    } else if (item ~ /^[\[\{]$/) {
        if ( JITER_STATE != T_DICT ) {
            JITER_CURLEN = JITER_CURLEN + 1
            obj[ JITER_FA_KEYPATH T_LEN ] = JITER_CURLEN
            JITER_FA_KEYPATH = JITER_FA_KEYPATH S "\"" JITER_CURLEN "\""
        } else {
            obj[ JITER_FA_KEYPATH T_LEN ] = JITER_CURLEN
            JITER_FA_KEYPATH = JITER_FA_KEYPATH S JITER_LAST_KP
            JITER_LAST_KP = ""
        }
        JITER_STATE = item
        JITER_CURLEN = 0

        obj[ JITER_FA_KEYPATH ] = item
        obj[ ++JITER_LEVEL ] = JITER_FA_KEYPATH
    } else {
        obj[ JITER_FA_KEYPATH T_LEN ] = JITER_CURLEN

        JITER_FA_KEYPATH = obj[ --JITER_LEVEL ]
        JITER_STATE = obj[ JITER_FA_KEYPATH ]
        JITER_CURLEN = obj[ JITER_FA_KEYPATH T_LEN ]
    }
}
# EndSection
