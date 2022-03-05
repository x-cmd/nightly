
# Section: utils
function cut_line( _line, _space_len,               _max_len_line, _option_after_arrl, _part_len){
    if( COLUMNS == "" )     return _line

    _max_len_line = COLUMNS - _space_len - 3 - 4
    if ( length(_line) < _max_len_line )  return _line

    _option_after_arrl = split( _line, _option_after_arr, " " )
    _part_len = 0
    for(key=1; key<=_option_after_arrl; ++key){
        _part_len += length(_option_after_arr[key]) + 1
        if (_part_len >= _max_len_line) {
            _part_len -= ( length(_option_after_arr[key]) + 1 )
            break
        }
    }
    # debug("_part_len:"_part_len";\t\tspace:"_space_len+7)
    return substr(_line, 1, _part_len) "\n" str_rep(" ", _space_len+7)  cut_line( substr(_line, _part_len + 1 ), _space_len )
}

# General default/candidate/regex rule string.
# Example: [default: fzf] [candidate: fzf, skim] [regex: ^(fzf|skim)$ ] ...
function generate_optarg_rule_string(option_id, optarg_idx,     _op, _regex, _candidate) {
    oparr_keyprefix = option_id KSEP optarg_idx KSEP OPTARG_OPARR
    _default = option_arr[ option_id KSEP optarg_idx KSEP OPTARG_DEFAULT ]
    _op = option_arr[ oparr_keyprefix KSEP 1 ]
    gsub("\005", " ", _default)

    if (_default != "" && _default != OPTARG_DEFAULT_REQUIRED_VALUE)    _default = " [default: " _default "]"

    if ( _op == "=~" )  return _default " [regex: "     str_joinwrap( "|",  "\"", "\"", option_arr, oparr_keyprefix KSEP, 2, option_arr[ oparr_keyprefix KSEP LEN ] ) "]"
    if ( _op == "="  )  return _default " [candidate: " str_joinwrap( ", ", "\"", "\"", option_arr, oparr_keyprefix KSEP, 2, option_arr[ oparr_keyprefix KSEP LEN ] ) "]"

    return _default
}
# EndSection

# Section: option_help

# Get max length of _opt_help_doc, and generate _opt_help_doc_arr.
function ___generate_help_cal_l_maxlen_helpdoc_helpdocarr(   obj,           i ){
    l = obj[ LEN ]
    _max_len = 0
    for (i=1; i<=l; ++i) {
        _opt_help_doc = get_option_string( obj[ i ] )       # obj[ i ] is option_ids
        if (length(_opt_help_doc) > _max_len)           _max_len = length(_opt_help_doc)
        _opt_help_doc_arr[ i ] = _opt_help_doc
    }
}

function generate_help_for_option_without_arg(   _return, i, _option_after,     l, _max_len, _opt_help_doc, _opt_help_doc_arr){
    ___generate_help_cal_l_maxlen_helpdoc_helpdocarr( flag_list )

    _return = "FLAGS:\n"
    for (i=1; i<=l; ++i) {
        option_id = flag_list[ i ]
        _space = str_rep(" ", _max_len-length(_opt_help_doc_arr[ i ]))
        _option_after = option_arr[option_id KSEP OPTION_DESC ] UI_END
        _option_after = cut_line(_option_after,_max_len)
        _return = _return "    " FG_BLUE _opt_help_doc_arr[ i ] _space "   " FG_LIGHT_RED _option_after "\n"
    }
    return _return
}

function generate_help_for_option_with_arg(     _return, i, _option_after,      l, _max_len, _opt_help_doc, _opt_help_doc_arr ){
    ___generate_help_cal_l_maxlen_helpdoc_helpdocarr( option_list )

    _return = "OPTIONS:\n"
    for (i=1; i<=l; ++i) {
        option_id = option_list[ i ]

        oparr_string  = ""
        option_argc   = option_arr[ option_id KSEP LEN ]
        for(j=1; j<=option_argc; ++j) oparr_string = oparr_string generate_optarg_rule_string(option_id, j)

        _multiple = match(option_id, /\\|m/) ? " [multiple]" : ""
        _option_after = option_arr[ option_list[ i ] KSEP OPTION_DESC ] UI_END oparr_string _multiple
        _option_after = cut_line(_option_after,_max_len)

        _space = str_rep(" ", _max_len-length(_opt_help_doc_arr[ i ]))
        _return = _return "    " FG_BLUE _opt_help_doc_arr[ i ] _space "   " FG_LIGHT_RED _option_after "\n"
    }
    return _return
}

# There are two types of options:
# 1. Options without arguments, is was flags.
# 2. Options with arguments.
#   For example, --flag1, --flag2, --flag3, ...
#   For example, --option1 value1, --option2 value2, --option3 value3, ...
function generate_option_help(         _return, i, option_list, flag_list) {
    # If option has no argument, push it to flag_list.
    # Otherwise, push it to option_list.
    for (i=1; i<=option_id_list[ LEN ]; ++i) {
        option_id     = option_id_list[ i ]
        option_argc   = option_arr[ option_id KSEP LEN ]

        if (option_argc == 0) {
            flag_list[ LEN ] = flag_list[ LEN ] + 1
            flag_list[ flag_list[ LEN ] ] = option_id
        } else {
            option_list[ LEN ] = option_list[ LEN ] + 1
            option_list[ option_list[ LEN ] ] = option_id
        }
    }

    _return = ""
    if (0 != flag_list[ LEN ])      _return = _return "\n" generate_help_for_option_without_arg()
    if (0 != option_list[ LEN ])    _return = _return "\n" generate_help_for_option_with_arg()
    return _return
}
# EndSection

# Section: rest_argument_help
function generate_rest_argument_help(        _option_help,_option_after) {
    # Get max length of rest argument name.
    _max_len = 0
    _option_after = ""
    for (i=1; i<=rest_option_id_list[ LEN ]; ++i) {
        if (length(rest_option_id_list[ i ]) > _max_len) _max_len = length(rest_option_id_list[ i ])
    }

    # Generate help doc.
    _option_help = _option_help "\nARGS:\n"
    for (i=1; i <= rest_option_id_list[ LEN ]; ++i) {
        option_id       = rest_option_id_list[ i ]

        oparr_string = generate_optarg_rule_string(option_id, 1)

        _option_after = option_arr[option_id KSEP OPTION_DESC ] UI_END oparr_string
        _option_after = cut_line(_option_after,_max_len)

        _space = str_rep(" ", _max_len-length(option_id))
        _option_help = _option_help "    " FG_BLUE option_id _space "   " FG_LIGHT_RED _option_after "\n"
    }
    return _option_help
}
# EndSection

# Section: subcommand_help
function generate_subcommand_help(        _option_help, _cmd_name) {
    # Get max length of subcommand name.
    _max_len = 0
    for (i=1; i<=subcmd_arr[ LEN ]; ++i) {
        if (length(subcmd_arr[ i ]) > _max_len) _max_len = length(subcmd_arr[ i ])
    }

    # Generate help doc.
    _option_help = _option_help "\nSUBCOMMANDS:\n"
    for (i=1; i <= subcmd_arr[ LEN ]; ++i) {
        _cmd_name = subcmd_arr[ i ]
        gsub("\\|", ",", _cmd_name)
        _space = str_rep(" ", _max_len-length(_cmd_name))

        _option_help = _option_help "    " FG_BLUE _cmd_name _space "\t" FG_LIGHT_RED str_unquote(subcmd_map[ subcmd_arr[ i ] ]) UI_END "\n"
    }

    return _option_help "\nRun 'CMD SUBCOMMAND --help' for more information on a command\n"
}
# EndSection

function print_helpdoc(){
    if (0 != option_id_list[ LEN ])         printf("%s", generate_option_help())
    if (0 != rest_option_id_list[ LEN ])    printf("%s", generate_rest_argument_help())
    if (0 != subcmd_arr[ LEN ])             printf("%s", generate_subcommand_help())
    printf("\n")
}

# TODO: make it end
NR==4{
    print_helpdoc()
    exit_now(0)
}

