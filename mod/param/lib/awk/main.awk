
function exec_help(){
    print "___x_cmd_param_int _x_cmd_help ;"
    if (exit_code == "")    exit_code = 0
    print "return " exit_code
    exit_now(1) # TODO: should I return 0?
}

BEGIN{
    HAS_SPE_ARG = false
    _X_CMD_PARAM_ARG_ = "_X_CMD_PARAM_ARG_"
}

NR==4 {
    if( arg_arr[1] == "_dryrun" ){
        DRYRUN_FLAG = true
        IS_INTERACTIVE = false
        arr_shift( arg_arr, 1 )
        handle_arguments()
        print "return 0"
        exit_now(0)
    }

    if ( arg_arr[1] == "help" )             if (! subcmd_exist_by_id( subcmd_id_by_name("help") ))      exec_help()
    if ( arg_arr[1] ~ /^(--help|-h)$/ )     if (! option_exist_by_alias( arg_arr[ 1 ] ))                exec_help()
}

###############################
# Line 5: Defaults As Map
###############################

NR>=5 {
    # Setting default values
    if (keyline == "") {
        line_arr_len = split($0, line_arr, ARG_SEP)
        objectname = line_arr[1]
        keyline = line_arr[2]
    } else {
        if (objectname == OBJECT_NAME)  option_default_map[keyline] = $0
        keyline = ""
    }
}
# EndSection

# Section: handle_arguments
function arg_typecheck_then_generate_code(option_id, optarg_id, arg_var_name, arg_val,
    def, tmp ){

    _ret = assert( optarg_id, arg_var_name, arg_val )
    if ( _ret == true ) {
        code_append_assignment( arg_var_name, arg_val )
    } else if ( ! is_interactive() ) {
        panic_error( _ret )
    } else {
        code_query_append_by_optionid_optargid( arg_var_name, option_id, optarg_id )
    }
}

function handle_arguments_restargv_typecheck( use_ui_form, i, argval, is_dsl_default,
    tmp, _option_id, _optarg_id){
    _option_id = option_get_id_by_alias( "#" i )
    _optarg_id = _option_id S 1

    if (argval != "") {
        _ret = assert(_optarg_id, "$" i, argval)
        if (_ret == true)                       return true
        else if (false == use_ui_form) {
            if (is_dsl_default == true)         panic_param_define_error(_ret)
            else                                panic_error( _ret )
        } else {
            code_query_append_by_optionid_optargid( _X_CMD_PARAM_ARG_ i, _option_id, _optarg_id )
            return false
        }
    }

    if (option_arr[ "#n" ] == "")     return true               # nth_rule

    _ret = assert(_optarg_id, "$" i, argval)
    if (_ret == true)                           return true
    else if (false == use_ui_form) {
        if (is_dsl_default == true)             panic_param_define_error(_ret)
        else                                    panic_error( _ret )
    } else {
        code_query_append_by_optionid_optargid( _X_CMD_PARAM_ARG_ i, _option_id, _optarg_id )
        return false
    }
}

function handle_arguments_restargv(         final_rest_argv_len, i, arg_val, option_id,
    named_value, _need_set_arg, set_arg_namelist, tmp, _index ){

    final_rest_argv_len = final_rest_argv[ L ]
    for ( i=1; i<=final_rest_argv_len; ++i) {
        set_arg_namelist[ i ] = i
    }

    _need_set_arg = false
    for ( i=1; i<=final_rest_argv_len; ++i) {
        if ( i <= arg_arr[ L ]) {
            arg_val = arg_arr[ i ]
            # To set the input value and continue
            if ( true != handle_arguments_restargv_typecheck( is_interactive(), i, arg_val, false ) ) {
                set_arg_namelist[ i ] = _X_CMD_PARAM_ARG_ i
                _need_set_arg = true
            }

            option_id = option_get_id_by_alias( "#" i )

            tmp = option_name_get_without_hyphen( option_id ); if( tmp == "" ) tmp = _X_CMD_PARAM_ARG_ i
            code_append_assignment( tmp, arg_val )
            set_arg_namelist[ i ] = tmp;                    _need_set_arg = true
        } else {
            option_id = option_get_id_by_alias( "#" i )
            named_value = rest_arg_named_value[ option_id ]

            # TODO: Using something better, like OPTARG_DEFAULT_REQUIRED_VALUE
            if (named_value != "") {
                tmp = option_name_get_without_hyphen( option_id )
                set_arg_namelist[ i ] = tmp;                _need_set_arg = true
                continue                # Already check
            }

            arg_val = optarg_default_get( option_id )
            if ( optarg_default_value_eq_require(arg_val) ) {
                # Don't define a default value
                # TODO: Why can't exit here???
                if (! is_interactive())   return panic_required_value_error( option_id )

                tmp = option_name_get_without_hyphen( option_id ); if (tmp == "") tmp = _X_CMD_PARAM_ARG_ i
                code_query_append_by_optionid_optargid( tmp, option_id, optarg_id )
                set_arg_namelist[ i ] = tmp;                _need_set_arg = true
            } else {
                # Already defined a default value
                # TODO: Tell the user, it is wrong because of default definition in DSL, not the input.
                handle_arguments_restargv_typecheck( false, i, arg_val, true )
                tmp = option_name_get_without_hyphen( option_id ); if (tmp == "") tmp = _X_CMD_PARAM_ARG_ i
                code_append_assignment( tmp, arg_val )
                set_arg_namelist[ i ] = tmp;                _need_set_arg = true
            }
        }
    }

    # TODO: You should set the default value, if you have no .
    if (QUERY_CODE != ""){
        QUERY_CODE = "local ___X_CMD_UI_FORM_EXIT_STRATEGY=\"execute|exit\"; x ui form " substr(QUERY_CODE, 9)
        QUERY_CODE = QUERY_CODE ";\nif [ \"$___X_CMD_UI_FORM_EXIT\" = \"exit\" ]; then return 1; fi;"
        code_append(QUERY_CODE)
        if( HAS_PATH == true){
            code_append( "local path >/dev/null 2>&1" )
            code_append( "path=$___x_cmd_param_path" )
        }
    }

    if (_need_set_arg == true) {
        code_append( "set -- " str_joinwrap( " ", "\"$", "\"", set_arg_namelist, "", 1, final_rest_argv_len  ) )
    }
}

function handle_arguments(          i, j, arg_name, arg_name_short, arg_val, option_id, option_argc, count, sw, arg_arr_len, _tmp, _subcmd_id ) {
    arg_arr_len = arg_arr[ L ]
    arr_clone(arg_arr, tmp_arr)
    i = 1; while (i <= arg_arr_len) {
        arg_name = arg_arr[ i ]
        # ? Notice: EXIT: Consider unhandled arguments are rest_argv
        if ( arg_name == "--" )  break
        if ( ( arg_name == "--help") || ( arg_name == "-h") )   exec_help()

        option_id = option_get_id_by_alias( arg_name )
        if ( option_id == ""  ) {
            if (arg_name ~ /^-[^-]/) {
                arg_name = substr(arg_name, 2)
                arg_len = split(arg_name, arg_arr, //)
                for (j=1; j<=arg_len; ++j) {
                    arg_name_short  = "-" arg_arr[ j ]
                    option_id       = option_get_id_by_alias( arg_name_short )
                    option_name     = option_name_get_without_hyphen( option_id )

                    if (option_name == "") {
                        HAS_SPE_ARG = true
                        break
                    }
                    code_append_assignment( option_name, "true" )
                }
                continue
            } else if( arg_name ~ /^--?/ ) {
                break
            }
        }
        if( HAS_SPE_ARG == true )        arr_clone(tmp_arr, arg_arr)

        option_arr_assigned[ option_id ] = true

        option_argc     = option_argc_get( option_id )
        option_m        = option_multarg_get( option_id )
        option_name     = ( option_alias_2_option_id[  option_id SPECIAL_OPTION_ID ] != "" ? option_alias_2_option_id[  option_id SPECIAL_OPTION_ID ] : option_name_get_without_hyphen( option_id ) )

        # If option_argc == 0, op
        if ( option_multarg_is_enable( option_id ) ) {
            counter = option_assignment_count[ option_id ] + 1      # option_assignment_count[ option_id ] can be ""
            option_assignment_count[ option_id ] = counter
            option_name = option_name "_" counter
        }
        # EXIT: Consider unhandled arguments are rest_argv
        if ( !( arg_name ~ /^--?/ ) ) break

        if (option_argc == 0) {
            # print code XXX=true
            code_append_assignment( option_name, "true" )
        } else if (option_argc == 1) {
            arg_val = arg_arr[ ++i ]

            if ( option_id ~ "^#" )     rest_arg_named_value[ option_id ] = arg_val     # NAMED REST_ARGUMENT
            if (i > arg_arr_len)        panic_required_value_error(option_id)

            arg_typecheck_then_generate_code(       option_id, option_id S 1,     option_name,            arg_val )
        } else {
            for ( j=1; j<=option_argc; ++j ) {
                arg_val = arg_arr[ ++i ]
                if (i > arg_arr_len)    panic_required_value_error(option_id)

                arg_typecheck_then_generate_code(   option_id, option_id S j,     option_name "_" j,      arg_val )
            }
        }
        i += 1
    }

    check_required_option_ready()

    # if subcommand declaration exists
    if ( HAS_SUBCMD == true ) {
        _subcmd_id = subcmd_id_by_name( arg_arr[i] )
        if (! subcmd_exist_by_id( _subcmd_id ) ) {
            HAS_SUBCMD = false  # No subcommand found
        } else {
            split( _subcmd_id , _tmp, "|" )
            code_append_assignment( "PARAM_SUBCMD", _tmp[1] )
            code_append( "shift " i )
            return
            # i += 1
        }
    }

    code_append( "shift " (i-1) )

    if (final_rest_argv[ L ] < arg_arr_len - i + 1) {
        final_rest_argv[ L ] = arg_arr_len - i + 1
    }

    #Remove the processed arg_arr and move the arg_arr back forward
    arr_shift( arg_arr, (i-1) )

    handle_arguments_restargv()
    if( HAS_PATH == true ){
        code_append( "local path >/dev/null 2>&1" )
        code_append( "path=$___x_cmd_param_path" )
    }
}

END{
    # if (EXIT_CODE == "000") code_print()    # TODO: Why?
    if (EXIT_CODE == 0) {
        handle_arguments()
        # debug( CODE )
        code_print()
    }
}
# EndSection
