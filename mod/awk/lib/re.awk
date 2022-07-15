
# [:alnum:]
# [:alpha:]
# [:space:]
# [:blank:]
# [:upper:]
# [:lower:]
# [:digit:] [0-9]
# [:xdigit:]
# [:punct:]
# [:cntrl:]
# [:graph:]
# [:print:]

# - to reprenset a ch in bracket must be the last ch

function re( p0, ch ){
    return "(" p0 ")" ch
}

BEGIN{
    RE_OR = "|"

    RE_SPACE = "[ \t\v\n]+"

    RE_NUMBER = "^[-+]?[0-9]+$"
    RE_NUM = "[-+]?(0|[1-9][0-9]*)([.][0-9]+)?([eE][+-]?[0-9]+)?"
    RE_REDUNDANT = "([ \t]*[\n]+)+"

    # RE_TRIM = re_or( "^" RE_SPACE, RE_SPACE "$" )
    RE_TRIM = "^" RE_SPACE RE_OR RE_SPACE "$"

    # RE_TRIM = re_or( "^[\n]+", "[\n]+$" )
}

BEGIN {
    RE_EMAIL = "[[:alnum:]_-]+@[[:alnum:]][A-Za-z0-9-]+.[[:alnum:]]+"    # Check this out ...
    RE_DIGIT = "[0-9]"      # [:digit:]
    RE_DIGITS = "[0-9]+"    # [:digit:]+

    RE_INT = "[+-]?([1-9][0-9]*)|0"
    RE_INT0 = "[+-]?[0-9]+"
    RE_FLOAT = RE_INT "(.[0-9]*)*"

    RE_UTF8_HAN = ""
    RE_UTF8_NON_ASCII = ""

    RE_033 = "\033\\[([0-9]+;)*[0-9]+m"

    RE_IP = ""

    RE_IP_A = ""
    RE_IP_B = ""
    RE_IP_C = ""
    RE_IP_D = ""
    RE_IP_E = ""

    RE_IP_SUBNET = ""
}

BEGIN{
    # /"[^"\\\001-\037]*((\\[^u\001-\037]|\\u[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F])[^"\\\001-\037]*)*"|-?(0|[1-9][0-9]*)([.][0-9]+)?([eE][+-]?[0-9]+)?|null|false|true|[ \t\n\r]+|./
    # RE_STR2_ORGINAL = "\"[^\"\\\\\001-\037]*((\\\\[^u\001-\037]|\\\\u[0-9a-fA-F]{4})[^\"\\\\\001-\037]*)*\""

    RE_QUOTE_CONTROL_OR_UNICODE = re( "\\\\[^u\001-\037]" RE_OR "\\\\u[0-9a-fA-F]{4}" )

    RE_NOQUOTE1 = "[^'\\\\\001-\037]*"
    RE_STR1 = "'"  RE_NOQUOTE1 re( RE_QUOTE_CONTROL_OR_UNICODE RE_NOQUOTE1, "*")  "'"

    RE_NOQUOTE2 = "[^\"\\\\\001-\037]*"
    RE_STR2 = "\"" RE_NOQUOTE2 re( RE_QUOTE_CONTROL_OR_UNICODE RE_NOQUOTE2, "*" ) "\""

    # RE_STR0 = "[^ \\t\\v\\n]*" "((\\\\[ ])[^ \\t\\v\\n]*)*"
    RE_STR0 = "(\\\\[ ])*[^ \t\v\n]+"  "((\\\\[ ])[^ \t\v\n]*)*"
}

# awk 'BEGIN{ match("-b+cd", "[[:alnum:][:punct:]]*"); print RLENGTH " " RSTART; }'


# [:email:]
# [:ip-a:]
# [:ip-b:]
# [:ip-c:]
# [:ip-d:]
# [:ip-e:]
# [:ipv6:]
# [:ip:192.168.0.0/16:]
# param design, consider the ip and number

# 0-65536
# 0-9, 10-99, 100-999, 1000-9999, 10000-65535


function re_range2pattern_all_digit( num, digit ){
    gsub(/[0-9]/, digit, num)
    return num
}


function re_range( start, end,      i, _startl, _endl, _res, _num9 ){
    _startl = length( start )
    _endl   = length( end )

    if (_startl == _endl)   return re_range2pattern( start, end )

    _num9   = re_range2pattern_all_digit( start, 9 )
    _num0   = 1 substr(re_range2pattern_all_digit( _num9, 0 ), 2)

    _res    = re_range2pattern_main( start, _num9 )

    for (i=_startl+1; i<_endl; ++i) {
        _res = _res "|" re_range2pattern_main( ( _num0 = _num0 "0" ), ( _num9 = _num9 "9" ) )
    }

    _res = _res "|" re_range2pattern_main( ( _num0 = _num0 "0" ), end )

    return "(" _res ")"
}

function re_range2pattern_main( start, end ){
    # print start, end
    return re_range2pattern(start, end)
}

# 1-13 = [1-9]
# 11-13 = 1[1-3]
# 128-192=[1](2[8-9])|([3-8])
function re_range2pattern( start, end,      l, _res, _rest_0, _rest_9, _start_a, _start_rest, _end_a, _end_rest, _mid_start, _mid_end ){
    l = length( start )
    if (l == 1)       return (start == end) ? start : sprintf("[%s-%s]", start, end)
    _start_a        = substr(start, 1, 1)
    _start_rest     = substr(start, 2, l-1)
    _end_a          = substr(end, 1, 1)
    _end_rest       = substr(end, 2, l-1)

    _rest_0         = re_range2pattern_all_digit( _start_rest, 0 )
    _rest_9         = re_range2pattern_all_digit( _start_rest, 9 )

    if (_start_a == _end_a) {
        return _start_a re_range2pattern( _start_rest, _end_rest )
    }

    _mid_start      = _start_a + 1
    _mid_end        = _end_a - 1

    _res = ""
    if (_start_rest == 0)       _mid_start -= 1
    else                        _res =  ((_res == "") ? "" : _res "|")  sprintf("(%s)", _start_a    re_range2pattern( _start_rest, _rest_9  ) )

    if ( _end_rest == _rest_9 ) _mid_end += 1
    else                        _res =  ((_res == "") ? "" : _res "|")  sprintf("(%s)", _end_a      re_range2pattern( _rest_0, _end_rest  ) )

    if (_mid_start == _mid_end) _res =  ((_res == "") ? "" : _res "|")  ( (l==2) ?  sprintf("(%s[0-9])",       _mid_start)          : sprintf("(%s[0-9]{%s})",      _mid_start, (l-1)) )
    if (_mid_start <  _mid_end) _res =  ((_res == "") ? "" : _res "|")  ( (l==2) ?  sprintf("([%s-%s][0-9])",  _mid_start, _mid_end) : sprintf("([%s-%s][0-9]{%s})", _mid_start, _mid_end, (l-1)) )
    return "(" _res ")"
}



function re_range_rest(){
    print re_range2pattern(10, 99)

    # ([0-9]|(([1-9][0-9]))|1((2[0-7])|([0-1][0-9])))

    print re_range(0, 65535)
    pat = "^" re_range(0, 65535) "$"

    for (i=0; i<=65535; ++i) {
        if (i !~ pat) print "Wrong i"
    }

    for (i=65536; i<=100000; ++i) {
        if (i ~ pat) print "Wrong " i
    }

    # print re_range2pattern(11, 13)
    # print re_range2pattern(11, 23)
    # print re_range2pattern(11, 33)
    # print re_range2pattern(11, 63)
    # print re_range2pattern(111, 863)
}

# END{
#     re_range_rest()
# }

function re_match( str, regex ){
    return 0
}

function re_patgen( regex ){
    gsub(/\[\:ip-a\:\]/, "", regex)
    gsub(/\[\:ip-b\:\]/, "", regex)
    gsub(/\[\:ip-c\:\]/, "", regex)
    gsub(/\[\:ip-d\:\]/, "", regex)
    gsub(/\[\:ip\:\]/, "", regex)
    gsub(/\[\:ip\:\]/, "", regex)
    gsub(/\[\:url\:\]/, "", regex)
    gsub(/\[\:httpx-url\:\]/, "", regex)

    # Calculate ...
    gsub(/\[\:[0-9]+-[0-9]+\:\]/, "", regex)

    return regex
}

