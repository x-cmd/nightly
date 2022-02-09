# TODO: what is for ?
function jgrep(obj, keypath, key, reg,      _k, _len, _ret){
    _k = keypath
    keypath = jpath(keypath)
    if (obj[ keypath ] != T_LIST) {
        exit(0)
        return
    }

    _len = obj[ keypath T_LEN ]
    if (_len <= 0) return

    for(_i=1; _i<=_len; ++_i){
        if( match(json_str_unquote2( obj[ jpath(_k "." _i key) ] ), reg)){
            _ret = _ret "\n" json_stringify_format(obj, _k "." _i, 4)
        }
    }
    return substr(_ret, 2)
}
