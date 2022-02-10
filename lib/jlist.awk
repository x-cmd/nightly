
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

# Section: 2arr
# TODO: to check
function jlist_id2arr(obj, keypath, range, arr,    i, l){
    jrange(range, obj[ keypath T_LEN ])

    l=0
    if (jrange_step > 0) {
        for (i=jrange_start; i<=jrange_end; i=i+jrange_step) {
            l = l + 1
            arr[l] = keypath S q(i)
        }
    } else {
        for (i=jrange_start; i>=jrange_end; i=i+jrange_step) {
            l = l + 1
            arr[l] = keypath S q(i)
        }
    }
    return l
}

function jlist_value2arr(obj, keypath, range, arr,    i, l){
    l = jlist_id2arr(obj, keypath, range, arr)
    for (i=1; i<=l; ++i) {
        arr[i] = obj[ arr[i] ]
    }
    return l
}

function jlist_str2arr(obj, keypath, range, arr,    i, l){
    l = jlist_id2arr(obj, keypath, range, arr)
    for (i=1; i<=l; ++i) {
        arr[i] = jstr( obj, arr[i])
    }
    return l
}

function jlist_str02arr(obj, keypath, range, arr,    i, l){
    l = jlist_id2arr(obj, keypath, range, arr)
    for (i=1; i<=l; ++i) {
        arr[i] = jstr0( obj, arr[i] )
    }
    return l
}

function jlist_str12arr(obj, keypath, range, arr,    i, l){
    l = jlist_id2arr(obj, keypath, range, arr)
    for (i=1; i<=l; ++i) {
        arr[i] = jstr1( obj, arr[i] )
    }
    return l
}
# EndSection

# It is not tested and not even implemented. What this function for ?
function jlist_grep(obj, keypath, key, reg,      _k, _len, _ret){
    _k = keypath
    keypath = jpath(keypath)
    if (obj[ keypath ] != T_LIST) {
        exit(0)
        return
    }

    _len = obj[ keypath T_LEN ]
    if (_len <= 0) return

    for(_i=1; _i<=_len; ++_i){
        if( match(json_str_unquote2( obj[ jpath(_k "." _i "." key) ] ), reg)){
            _ret = _ret "\n" json_stringify_format(obj, _k "." _i, 4)
        }
    }
    return substr(_ret, 2)
}


# Section: join, when joining, you should unwrap the value

# TOTEST
function jlist_join(sep, obj, keypath, range,      _ret_arr, i, l, _ret){
    l = jlist_value2arr(obj, keypath, range, _ret_arr)

    ret = ""
    for (i=1; i<=l; ++i) {
        if (ret != "")  ret = ret sep _ret_arr[i]
        else            ret = _ret_arr[i]
    }
    return ret
}

# TODO
function jlist_totable(){
    return true
}

# EndSection

