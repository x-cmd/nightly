
{
    if (length($0) != 1) {
        next
    }

    if (_utf8_l == 0) {
        _wchar = $0
        _utf8_l = ord_leading1( ord($0) )
        if ( 0 != _utf8_l )   _utf8_l = _utf8_l - 1
    } else {
        _wchar = _wchar $0
        _utf8_l --
    }
    if (_utf8_l == 0) print _wchar
}
