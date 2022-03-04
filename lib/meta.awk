# Section: 4-Arguments and intercept for help and advise            5-DefaultValues
function ls_option(         i, j, k,tmp_len,option_id,tmp,option_desc,option_argc,oparr_keyprefix,_op,option_default,_optarr_len,_regex,_candidate,_default){
    for (i=1; i<=advise_arr[ LEN ]; ++i) {
        # TODO: Can be optimalize.
        tmp_len=split(advise_arr[ i ], tmp)
        if ( option_alias_2_option_id[ tmp[1] ] != "" ){
            option_id = option_alias_2_option_id[ tmp[1] ]
        } else {
            option_id = tmp[1]
        }

        for (j=2; j<=tmp_len; ++j) {
            advise_map[ option_id ] = advise_map[ option_id ] " " tmp[j]
        }
        advise_map[ option_id ] = str_trim( advise_map[ option_id ] )
    }

    for (i=1; i<=option_id_list[ LEN ]; ++i) {
        option_id = option_id_list[i]
        print option_id
        option_desc = option_arr[ option_id KSEP OPTION_DESC ]
        print option_desc

        option_argc   = option_arr[ option_id KSEP LEN ]
        if( option_argc == 0 ){
            printf "\n\n"
        }
        for(j=1; j<=option_argc; ++j) {
            oparr_keyprefix = option_id KSEP j KSEP OPTARG_OPARR
            _op = option_arr[ oparr_keyprefix KSEP 1 ]
            option_default = option_arr[ option_id KSEP j KSEP OPTARG_DEFAULT ]
            if (option_default != "" && option_default != OPTARG_DEFAULT_REQUIRED_VALUE) {
                print "\006"option_default
            }

            if ( _op == "=~" ) {
                _optarr_len = option_arr[ oparr_keyprefix KSEP LEN ]
                for ( k=1; k<=_optarr_len; ++k ) {
                    _regex = "\"" option_arr[ oparr_keyprefix KSEP k ] "\""
                    printf str_unquote(_regex)"\006"
                }
                printf "\n"
            }else if ( _op == "=" ) {
                _optarr_len = option_arr[ oparr_keyprefix KSEP LEN ]
                for ( k=1; k<=_optarr_len; ++k ) {
                    _candidate = "\"" option_arr[ oparr_keyprefix KSEP k ] "\""
                    printf str_unquote(_candidate)"\006"
                }
                printf "\n"
            }
        }
        if (advise_map[ option_id ] != "") {
            print advise_map[option_id]
            continue
        }else{
            printf "\n"
        }
    }

    for (i=1; i <= rest_option_id_list[ LEN ]; ++i) {
        option_id       = rest_option_id_list[ i ]
        print option_id
        option_desc = option_arr[ option_id KSEP OPTION_DESC ]
        print option_desc

        _default = option_arr[ option_id KSEP 1 KSEP OPTARG_DEFAULT ]
        if (_default != "" && _default != OPTARG_DEFAULT_REQUIRED_VALUE) {
            print "\006"_default
        }else{
            printf "\n"
        }

        oparr_keyprefix = option_id KSEP 1 KSEP OPTARG_OPARR
        _op = option_arr[ oparr_keyprefix KSEP 1 ]
        if ( _op == "=~" ) {
            _optarr_len = option_arr[ oparr_keyprefix KSEP LEN ]
            for ( k=1; k<=_optarr_len; ++k ) {
                _regex = "\"" option_arr[ oparr_keyprefix KSEP k ] "\""
                printf str_unquote(_regex)"\006"
            }
            printf "\n"
        }else if(_op == "=") {
            _optarr_len = option_arr[ oparr_keyprefix KSEP LEN ]
            for ( k=1; k<=_optarr_len; ++k ) {
                _candidate = "\"" option_arr[ oparr_keyprefix KSEP k ] "\""
                printf str_unquote(_candidate)"\006"
            }
            printf "\n"
        }else{
            printf "\n"
        }

        if (advise_map[ option_id ] != "") {
            print advise_map[option_id]
            continue
        }else{
            printf "\n"
        }
    }
}

function ls_subcmd(         i,_cmd_name){
    for (i=1; i <= subcmd_arr[ LEN ]; ++i) {
        _cmd_name = subcmd_arr[ i ]
        print _cmd_name
        print str_unquote(subcmd_map[ subcmd_arr[ i ] ])
    }
}


NR==4{
    if ( arg_arr[1] == "_param_list_subcmd" ) {
        for (i=1; i <= subcmd_arr[ LEN ]; ++i) {
            subcmd_elearr_len = split( subcmd_arr[ i ], subcmd_elearr, "|" )
            for (j=1; j<=subcmd_elearr_len; ++j)
                print "printf \"%s\n\" " subcmd_elearr[ j ]
        }
        print "return 0"
        exit_now(1)
    }

    if( arg_arr[1] == "_param_has_subcmd" ){
        for(i=1; i<=subcmd_arr[ LEN ]; ++i){
            if( subcmd_arr[i] == arg_arr[2] ){
                exit 0
            }
        }
        exit 1
    }

    if( arg_arr[1] == "_ls_subcmd" ){
        ls_subcmd()
        exit_now(0)
    }

    if( arg_arr[1] == "_ls_option" ){
        ls_option()
        exit_now(0)
    }

    if( arg_arr[1] == "_ls_option_subcmd" ){
        ls_option()
        print "---------------------"
        ls_subcmd()
        print "---------------------"
        for(i=1; i <= arg_arr[ LEN ]; ++i){
            print arg_arr[i]
        }
        exit_now(0)
    }
}
