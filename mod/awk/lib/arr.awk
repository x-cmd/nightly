BEGIN {
    # LEN = "\001"
    LEN = L
    NULL = "\001"
}

function arr_len(arr){
    return arr[ LEN ]
}

function arr_seq( s, sep, e,        _arr, i ){
    for (i=1; s<=e; s+=sep) _arr[i++] = s
    return _arr
}

function arr_eq( a1, a2,    i, l ){
    l = length(a1)
    if (l != length(a2)) return false
    for (i=1; i<=l; i++) if (a1[i] != a2[i]) return false
    return true
}

function arr_push(arr, elem, _len){
    _len = arr[ LEN ] + 1
    arr[ _len ] = elem
    arr[ LEN ] = _len
}

function arr_pop(arr, _len){
    _len = arr[ LEN ]
    if (_len < 1) {
        return NULL
    }
    arr[ LEN ] = _len - 1

    _len = arr[ _len + 1 ]
    arr[ _len + 1 ] = ""
    return _len
}

function arr_top(arr) {
    _len = arr[ LEN ]
    if (_len < 1) {
        return NULL
    }
    return arr[ _len ]
}

function arr_join(arr, sep, _start, _len, _i, _result) {
    if (sep == "")      sep = "\n"
    if (_start == "")   _start = 1
    if (_len == "" )    _len = arr[ LEN ]

    if (_len < 1) return ""

    _result = arr[1]
    for (_i=2; _i<=_len; ++_i) {
        _result = _result sep arr[_i]
    }
    return _result
}

function arr_clone( src, dst,   l, i ){
    l = src[ L ]
    dst[ L ] = l
    for (i=1; i<=l; ++i)  dst[i] = src[i]
}

function arr_shift( arr, offset,        l, i ){
    l = arr[ L ] - offset
    for (i=1; i<=l; ++i) arr[i] = arr[i+offset]
    arr[ L ] = l
}


