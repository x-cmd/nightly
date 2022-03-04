# Section: 4-Arguments and intercept for help and advise            5-DefaultValues
function print_optarg( option_id, optarg_idx,            _option_default, _oparr_keyprefix, _op, _optarr_len, k ){
    _option_default = option_arr[ option_id KSEP optarg_idx KSEP OPTARG_DEFAULT ]
    if (_option_default != "" && _option_default != OPTARG_DEFAULT_REQUIRED_VALUE)  printf("%s", "\006" _option_default)
    printf("\n")

    _oparr_keyprefix = option_id KSEP optarg_idx KSEP OPTARG_OPARR
    _op = option_arr[ _oparr_keyprefix KSEP 1 ]
    if ( _op == "=~" ) {
        _optarr_len = option_arr[ _oparr_keyprefix KSEP LEN ]
        for ( k=1; k<=_optarr_len; ++k ) {
            # TODO: ?
            _regex = "\"" option_arr[ _oparr_keyprefix KSEP k ] "\""
            printf("%s", str_unquote(_regex) "\006")
        }
    } else if ( _op == "=" ) {
        _optarr_len = option_arr[ _oparr_keyprefix KSEP LEN ]
        for ( k=1; k<=_optarr_len; ++k ) {
            # TODO: ?
            _candidate = "\"" option_arr[ _oparr_keyprefix KSEP k ] "\""
            printf("%s", str_unquote(_candidate) "\006")
        }
    }
    printf("\n")
}

function ls_option(         i, _tmp_len, _option_id, _tmp, _option_argc){
    for (i=1; i<=advise_arr[ LEN ]; ++i) {
        # TODO: Can be optimalize.
        _tmp_len=split(advise_arr[ i ], _tmp)

        _option_id = option_alias_2_option_id[ _tmp[1] ]
        if ( _option_id == "" )      _option_id = _tmp[1]

        advise_map[ _option_id ] = str_trim( advise_map[ _option_id ] " " str_join( " ", _tmp, "", 2, _tmp_len ) )
    }

    for (i=1; i<=option_id_list[ LEN ]; ++i) {
        _option_id = option_id_list[i]
        printf("%s\n", _option_id)
        printf("%s\n", option_arr[ _option_id KSEP OPTION_DESC ])

        _option_argc = option_arr[ _option_id KSEP LEN ]
        if( _option_argc == 0 )  printf("\n\n")
        for(j=1; j<=_option_argc; ++j)   print_optarg( _option_id, j )

        printf("%s\n", (advise_map[ _option_id ] != "") ? advise_map[_option_id] : "")
    }

    for (i=1; i <= rest_option_id_list[ LEN ]; ++i) {
        _option_id = rest_option_id_list[ i ]
        printf("%s\n", _option_id)
        printf("%s\n", option_arr[ _option_id KSEP OPTION_DESC ])

        print_optarg( _option_id, 1 )

        printf("%s\n", (advise_map[ _option_id ] != "") ? advise_map[_option_id] : "")
    }
}

function ls_subcmd(         i,_cmd_name){
    for (i=1; i <= subcmd_arr[ LEN ]; ++i) {
        _cmd_name = subcmd_arr[ i ]
        printf("%s\n", _cmd_name)
        printf("%s\n", str_unquote( subcmd_map[ _cmd_name ] ))
    }
}

NR==4{
    if( arg_arr[1] == "_param_has_subcmd" ){
        for(i=1; i<=subcmd_arr[ LEN ]; ++i) if( subcmd_arr[i] == arg_arr[2] ) exit 0
        exit 1
    }
    else if( arg_arr[1] == "_ls_subcmd" || arg_arr[1] == "_param_list_subcmd" )           ls_subcmd()
    else if( arg_arr[1] == "_ls_option" )                                                 ls_option()
    else if( arg_arr[1] == "_ls_option_subcmd" ){
        ls_option()
        printf("---------------------\n")
        ls_subcmd()
        printf("---------------------\n")
        for(i=1; i <= arg_arr[ LEN ]; ++i)      printf("%s\n", arg_arr[i])
    }
    else exit 1

    exit 0
}
