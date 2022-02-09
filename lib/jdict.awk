
# TODO: rename to jdict_keys2arr
function jdict_keys(arr, keypath, klist, _l){
    _l = split(arr[ keypath T_KEY ], klist, S)
    klist[ L ] = _l
    # TODO: klist[ L ] = _l-1
    return _l
}

function jdict_keys2arr(arr, keypath, klist, _l){
    _l = split(arr[ keypath T_KEY ], klist, S)
    klist[ L ] = _l
    # TODO: klist[ L ] = _l-1
    return _l
}


function jdict_rm(arr, keypath, key,  _key_str){
    _key_str = arr[ keypath T_KEY]
    if (match(_key_str, S key)){
        arr[ keypath T_KEY ] = substr(_key_str, 1, RSTART - 1) substr(_key_str, RSTART + RLENGTH)
        arr[ keypath T_LEN ] = arr[ keypath T_LEN ] - 1
    }
}

# TODO: We should quote
function jdict_push(arr, keypath, key, value,  _v){
    _v = arr[keypath S key]
    if ( _v != "" ) {
        arr[keypath S key] = value
    } else {
        arr[ keypath T_LEN ] = arr[ keypath T_LEN ] + 1
        arr[ keypath T_KEY ] = arr[ keypath T_KEY ] S key
        # TODO: arr[ keypath T_KEY ] = arr[ keypath T_KEY ] key S
        arr[keypath S key] = value
    }
    return _v
}

function jdict_has(arr, keypath, key,  _v) {
    _v = arr[keypath S key]
    return (_v == "") ? false : true
}

function jdict_get(arr, keypath, key){
    return arr[keypath S key]
}

function jdict_len(arr, keypath){
    return arr[ keypath T_LEN ]
}

# TODO: to check
function jdict_value2arr(obj, keypath, arr,    _keyarr, i, l){
    l = jdict_keys2arr(obj, keypath, _keyarr)
    for (i=1; i<=l; ++i) {
        arr[i] = jstr(obj, keypath S i)
    }
    arr[ L ] = l
    return l
}

function jdict_grep(){

}
