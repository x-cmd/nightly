
function jlist_push(arr, keypath, value,  _l){
    _l = arr[ keypath T_LEN ] + 1
    arr[ keypath S "\"" _l "\""] = value
    arr[ keypath T_LEN ] = _l
}

function jlist_has(arr, keypath, value,  _l, _i) {
    _l = arr[ keypath T_LEN ]
    for (_i=1; _i<=_l; ++_i) {
        if ( arr[keypath S "\""_i "\"" ] == value ) {
            return true
        }
    }
    return false
}

function jlist_rm(arr, keypath, value,  _l, _i, _found_idx) {
    _l = arr[ keypath T_LEN ]
    _found_idx = 0
    for (_i=1; _i<=_l; ++_i) {
        if (_found_idx != 0) {
            arr[ keypath S "\"" _i - 1 "\"" ] = arr[ keypath S "\"" _i "\""]
        }
        if ( arr[keypath S "\""_i "\"" ] == value ) {
            _found_idx = _i
        }
    }
    if (_found_idx != 0) {
        arr[ keypath T_LEN ] = arr[ keypath T_LEN ] - 1
    }
    return _found_idx
}

function jlist_len(arr, keypath){
    return arr[ keypath T_LEN ]
}

# TODO: to check
function jlist_value2arr(obj, keypath, arr,    i, l){
    l = jlist_len(obj, keypath)
    for (i=1; i<=l; ++i) {
        arr[i] = jstr(obj, keypath S i)
    }
    arr[ L ] = l
    return l
}

function jlist_select2arr(obj, keypath, range, arr,    i, l){
    jrange(range, obj[ _kp T_LEN ])

    l=0
    if (jrange_step > 0) {
        for (i=jrange_start; i<=jrange_end; i=i+jrange_step) {
            l = l + 1
            arr[l] = obj[ keypath S i ]
        }
    } else {
        for (i=jrange_start; i>=jrange_end; i=i+jrange_step) {
            l = l + 1
            arr[l] = obj[ keypath S i ]
        }
    }
    return l
}

# Section: join, when joining, you should unwrap the value

# TOTEST
function jlist_join(sep, obj, keypath, range,      _ret_arr, i, l, _ret){
    if (range == "") {
        l = jlist_value2arr(obj, keypath, _ret_arr)
    } else {
        l = jlist_select2arr(obj, keypath, range, _ret_arr)
    }

    ret = ""
    for (i=1; i<=l; ++i) {
        if (ret != "")  ret = ret sep _ret_arr[i]
        else            ret = _ret_arr[i]
    }
    return ret
}

# EndSection

