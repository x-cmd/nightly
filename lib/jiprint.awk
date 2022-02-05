

# jiprint(arr, _jpath, start:end, sep1)
# jiprint(arr, _jpath, start:end, sep1, keystr, sep2)

function jiprint(arr, _jpath, range, sep1, keystr, sep2,   keyarrl, keyarr){
    keyarrl = json_jpaths2arr(keyarr, keystr)
    return _jiprint(arr, _jpath, range, sep1, keyarrl, keyarr, sep2)
}

function jiprint_table_title(arr,
    sep1, keystr,
    _title){
    _title = json_namedjpaths2arr(keyarr)
    printf("%s", _title sep1)
}

function jiprint_table( arr, _jpath, range, sep1, keystr, sep2,   keyarrl, keyarr ){
    if (keystr == "") {
        return _jiprint(arr, _jpath, range, sep1)
    }

    jiprint_table_title(arr, sep1, keystr)
    return _jiprint(arr, _jpath, range, sep1, keyarrl, keyarr, sep2)
}

# Section: _jiprint

function jprint_item(){

}

function _jiprint(arr, _jpath, range, sep1, keyarrl, keyarr, sep2,
    _kp, _len, _i, _j, _range, _rangel) {

    _kp = jpath(_jpath)

    jrange(range, arr[ _kp T_LEN ])

    if (jrange_step > 0) {
        for (_i=jrange_start; _i <= jrange_end; _i = _i + jrange_step) {
            printf("%s", json_str_unquote2( arr[ _kp S "\"" _i "\"" S keyarr[1] ] ) )
            for (_j=2; _j<=keyarrl; ++_j) {
                printf(sep2 "%s", json_str_unquote2( arr[ _kp S "\"" _i "\"" S keyarr[_j] ] ) )
            }

            if (_i<jrange_end) printf(sep1)
        }
    } else {
        for (_i=jrange_start; _i >= jrange_end; _i = _i + jrange_step) {
            printf("%s", json_str_unquote2( arr[ _kp S "\"" _i "\"" S keyarr[1] ] ) )
            for (_j=2; _j<=keyarrl; ++_j) {
                printf(sep2 "%s", json_str_unquote2( arr[ _kp S "\"" _i "\"" S keyarr[_j] ] ) )
            }
            if (_i>jrange_end) printf(sep1)
        }
    }
}

# EndSection

# Section: list
BEGIN {
    JIPRINT_LIST_LEN = 0
}

function jiprint_list(value){
    if (value == "") {
        print "\n]"
        JIPRINT_LIST_LEN = 0
        return
    }

    if (JIPRINT_LIST_LEN == 1) {
        print ",\n" value
    } else {
        JIPRINT_LIST_LEN = 1
        print "["
        print value
    }
}
# EndSection

# Section: dict
BEGIN {
    JIPRINT_DICT_LEN = 0
}

function jiprint_dict(key, value){
    if (key == "") {
        print "\n}"
        JIPRINT_DICT_LEN = 0
        return
    }

    if (JIPRINT_DICT_LEN == 1) {
        print ",\n" key "\n,\n" value
    } else {
        JIPRINT_DICT_LEN = 1
        print "{\n" key "\n,\n" value
    }
}

# EndSection
