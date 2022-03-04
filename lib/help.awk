
# Section: Generate Help Doc

function print_helpdoc_getitem(oparr_keyprefix,
    op, oparr_string, op_arr_len,
    k){

    op = option_arr[ oparr_keyprefix KSEP 1 ]
    if ( op == "" ) return ""

    oparr_string    = "<"
    op_arr_len = option_arr[ oparr_keyprefix KSEP LEN ]
    for ( k=2; k<=op_arr_len; ++k ) {
        oparr_string = oparr_string option_arr[ oparr_keyprefix KSEP k ] "|"
    }

    oparr_string = substr(oparr_string, 1, length(oparr_string)-1) ">"
    if (oparr_string == ">") oparr_string = ""

    return op "\t" oparr_string
}

function get_space(space_len,
    _space, _j){
    _space = ""
    for ( _j=1; _j<=space_len; ++_j ) {
        _space = _space " "
    }
    return _space
}

function cut_line(_line,_space_len,_option_line,_len_line,_max_len_line,_option_after_len,_option_after_arr_len){
    if( COLUMNS == "" ){
        return _line
    }
    _option_line = ""
    _option_after_arr_len = 0
    _len_line = length(_line)
    _max_len_line = COLUMNS-_space_len-3-4
    _option_after_len = split(_line,_option_after_arr," ")
    if (_len_line >= _max_len_line) {
        # for(key in _option_after_arr){
        for(key=1; key<=_option_after_len; ++key){
            _option_after_arr_len=_option_after_arr_len+length(_option_after_arr[key])+1
            if(_option_after_arr_len >= _max_len_line) {
                _option_after_arr_len = _option_after_arr_len-length(_option_after_arr[key])-1
                break
            }
        }
        # debug("_option_after_arr_len:"_option_after_arr_len";\t\tspace:"_space_len+7)
        _option_line = _option_line substr(_line, 1, _option_after_arr_len) "\n" get_space(_space_len+7)  cut_line(substr(_line,_option_after_arr_len+1),_space_len)
    } else {
        _option_line = _option_line _line
    }
    return _option_line
}

# There are two types of options:
# 1. Options without arguments, is was flags.
# 2. Options with arguments.
#   For example, --flag1, --flag2, --flag3, ...
#   For example, --option1 value1, --option2 value2, --option3 value3, ...
function generate_option_help(         _option_help, i, j, k, option_list, flag_list,_option_after) {

    # If option has no argument, push it to flag_list.
    # Otherwise, push it to option_list.
    for (_i=1; _i<=option_id_list[ LEN ]; ++_i) {
        option_id     = option_id_list[ _i ]
        option_argc   = option_arr[ option_id KSEP LEN ]

        if (option_argc == 0) {
            flag_list[ LEN ] = flag_list[ LEN ] + 1
            flag_list[ flag_list[ LEN ] ] = option_id
        } else {
            option_list[ LEN ] = option_list[ LEN ] + 1
            option_list[ option_list[ LEN ] ] = option_id
        }
    }

    # Generate help doc for options without arguments.
    if (0 != flag_list[ LEN ]) {
        # Get max length of _opt_help_doc, and generate _opt_help_doc_arr.
        _max_len = 0
        _option_after = ""
        for (i=1; i<=flag_list[ LEN ]; ++i) {
            option_id = flag_list[ i ]
            _opt_help_doc = get_option_string(option_id)

            if (length(_opt_help_doc) > _max_len) _max_len = length(_opt_help_doc)
            _opt_help_doc_arr[ i ] = _opt_help_doc
        }
        # Generate help doc.
        _option_help = _option_help "\nFLAGS:\n"
        for (i=1; i<=flag_list[ LEN ]; ++i) {
            option_id = flag_list[ i ]
            _space = get_space(_max_len-length(_opt_help_doc_arr[ i ]))
            _option_after = option_arr[option_id KSEP OPTION_DESC ] UI_END
            _option_after = cut_line(_option_after,_max_len)
            _option_help = _option_help "    " FG_BLUE _opt_help_doc_arr[ i ] _space "   " FG_LIGHT_RED _option_after"\n"
        }
    }

    # Generate help doc for options with arguments.
    if (0 != option_list[ LEN ]) {
        # Get max length of _opt_help_doc, and generate _opt_help_doc_arr.
        _max_len = 0
        _option_after = ""
        for (i=1; i<=option_list[ LEN ]; ++i) {
            _opt_help_doc = get_option_string( option_list[ i ] )

            if (length(_opt_help_doc) > _max_len) _max_len = length(_opt_help_doc)
            _opt_help_doc_arr[ i ] = _opt_help_doc
        }

        # Generate help doc.
        _option_help = _option_help "\nOPTIONS:\n"
        for (i=1; i<=option_list[ LEN ]; ++i) {
            # Generate default/candidate/regex help doc.
            # Example: [default: fzf] [candidate: fzf, skim] [regex: ^(fzf|skim)$ ] ...
            option_id = option_list[ i ]
            option_argc   = option_arr[ option_id KSEP LEN ]
            oparr_string  = ""
            for(j=1; j<=option_argc; ++j) {
                oparr_keyprefix = option_id KSEP j KSEP OPTARG_OPARR
                _default = option_arr[ option_id KSEP j KSEP OPTARG_DEFAULT ]
                _op = option_arr[ oparr_keyprefix KSEP 1 ]
                _regex = ""
                _candidate = ""
                gsub("\005", " ", _default)
                if (_default != "" && _default != OPTARG_DEFAULT_REQUIRED_VALUE) {
                    _default = " [default: " _default "]"
                }

                if ( _op == "=~" ) {
                    _optarr_len = option_arr[ oparr_keyprefix KSEP LEN ]
                    for ( k=2; k<=_optarr_len; ++k ) {
                        _regex = _regex "\"" option_arr[ oparr_keyprefix KSEP k ] "\"" "|"
                    }
                    _regex = " [regex: " substr(_regex, 1, length(_regex)-1) "]"

                } else if ( _op == "=" ) {
                    _optarr_len = option_arr[ oparr_keyprefix KSEP LEN ]
                    for ( k=2; k<=_optarr_len; ++k ) {
                        _candidate = _candidate "\"" option_arr[ oparr_keyprefix KSEP k ] "\"" ", "
                    }
                    _candidate = " [candidate: " substr(_candidate, 1, length(_candidate)-2) " ]"
                }

                oparr_string = oparr_string _default _candidate _regex
            }

            if (match(option_id, /\\|m/)) {
                _multiple = " [multiple]"
            } else {
                _multiple = ""
            }

            _space = get_space(_max_len-length(_opt_help_doc_arr[ i ]))
            _option_after = option_arr[ option_list[ i ] KSEP OPTION_DESC ] UI_END oparr_string _multiple
            _option_after = cut_line(_option_after,_max_len)
            _option_help = _option_help "    " FG_BLUE _opt_help_doc_arr[ i ] _space "   " FG_LIGHT_RED _option_after"\n"
        }
    }

    return _option_help
}

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
        oparr_keyprefix = option_id KSEP 1 KSEP OPTARG_OPARR
        oparr_string = print_helpdoc_getitem(oparr_keyprefix)
        _space = get_space(_max_len-length(option_id))

        oparr_string  = ""

        _default = option_arr[ option_id KSEP 1 KSEP OPTARG_DEFAULT ]
        _op = option_arr[ oparr_keyprefix KSEP 1 ]
        _regex = ""
        _candidate = ""

        if (_default != "" && _default != OPTARG_DEFAULT_REQUIRED_VALUE) {
            _default = " [default: " _default "]"
        }

        if ( _op == "=~" ) {
            _optarr_len = option_arr[ oparr_keyprefix KSEP LEN ]
            for ( k=2; k<=_optarr_len; ++k ) {
                _regex = _regex "\"" option_arr[ oparr_keyprefix KSEP k ] "\"" "|"
            }
            _regex = " [regex: " substr(_regex, 1, length(_regex)-1) "]"

        } else if(_op == "=") {
            _optarr_len = option_arr[ oparr_keyprefix KSEP LEN ]
            for ( k=2; k<=_optarr_len; ++k ) {
                _candidate = _candidate "\"" option_arr[ oparr_keyprefix KSEP k ] "\"" ", "
            }
            _candidate = " [candidate: " substr(_candidate, 1, length(_candidate)-2) " ]"
        }

        oparr_string = oparr_string _default _candidate _regex
        _option_after = option_arr[option_id KSEP OPTION_DESC ] UI_END oparr_string
        _option_after = cut_line(_option_after,_max_len)
        _option_help = _option_help "    " FG_BLUE option_id _space "   " FG_LIGHT_RED _option_after "\n"
    }
    return _option_help
}

function generate_subcommand_help(        _option_help) {
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
        _space = get_space(_max_len-length(_cmd_name))

        _option_help = _option_help "    " FG_BLUE _cmd_name _space "\t" FG_LIGHT_RED str_unquote(subcmd_map[ subcmd_arr[ i ] ]) UI_END "\n"
    }

    _option_help = _option_help "\nRun 'CMD SUBCOMMAND --help' for more information on a command\n"

    return _option_help
}

function print_helpdoc(exit_code,
    HELP_DOC){

    if (0 != option_id_list[ LEN ]) {
        HELP_DOC = HELP_DOC generate_option_help()
    }

    if (0 != rest_option_id_list[ LEN ]) {
        HELP_DOC = HELP_DOC generate_rest_argument_help()
    }

    if (0 != subcmd_arr[ LEN ]) {
        HELP_DOC = HELP_DOC generate_subcommand_help()
    }
    print HELP_DOC
}

# EndSection

# TODO: make it end
NR==4{
    print_helpdoc()
    exit_now(0)
}

