
# shellcheck shell=bash

# get the candidate value
function advise_get_candidate_code( curval, genv, lenv, obj, kp,        _candidate_code, i, j, l, v, _option_id, _cand_key, _cand_l, _desc, _arr_value, _arr_valuel ) {
    l = obj[ kp L ]
    for (i=1; i<=l; ++i) {
        _option_id = obj[ kp, i ]
        if ( _option_id == "\"#cand\"" ) {
            _cand_key = kp SUBSEP _option_id
            _cand_l = obj[ _cand_key L ]
            for (j=1; j<=_cand_l; ++j) {
                v = obj[ _cand_key, "\"" j "\"" ]
                if( v ~ "^\"" curval ) _candidate_code = _candidate_code v "\n"
            }
        }
        if ( _option_id ~ "^\"#") continue

        _desc = ( ZSHVERSION != "" ) ? juq(obj[ kp SUBSEP _option_id SUBSEP "\"#desc\"" ]) : ""
        _arr_valuel = split( juq( _option_id ), _arr_value, "|" )
        for ( j=1; j<=_arr_valuel; ++j) {
            v =_arr_value[j]
            if ((v ~ "^"curval) && (lenv[ _option_id ] == "")) {
                if (( curval == "" ) && ( v ~ "^-" )) if ( ! aobj_istrue(obj, kp SUBSEP _option_id SUBSEP "\"#subcmd\"" ) ) continue
                if (( curval == "-" ) && ( v ~ "^--" )) continue
                if ( _desc != "" ) _candidate_code = _candidate_code jqu(v ":" _desc) "\n"
                else _candidate_code = _candidate_code jqu(v) "\n"
            }
        }
    }
    return _candidate_code
}

function advise_complete___generic_value( curval, genv, lenv, obj, kp, _candidate_code,         _exec_val, _regex_key_arr, _regex_key_arrl, i ){

    CODE = CODE "\n" "candidate_arr=(" "\n"
    if ( _candidate_code != "" ) CODE = CODE "\n" _candidate_code
    CODE = CODE advise_get_candidate_code( curval, genv, lenv, obj, kp )
    CODE = CODE ")"

    _exec_val = obj[ kp SUBSEP "\"#exec\"" ]
    if ( _exec_val != "" ) CODE = CODE "\n" "candidate_exec=" _exec_val ";"

    _regex_key_arr = kp SUBSEP "\"#regex\""
    _regex_key_arrl = obj[ _regex_key_arr L ]
    if ( _regex_key_arrl != "" ) {
        CODE = CODE "\n" "candidate_regex=(" "\n"
        for (i=1; i<=_regex_key_arrl; ++i) {
            CODE = CODE obj[ _regex_key_arr, "\"" i "\"" ] "\n"
        }
        CODE = CODE ")"
    }

    # TODO: Other code
    return CODE
}

# Just show the value
function advise_complete_option_value( curval, genv, lenv, obj, obj_prefix, option_id, arg_nth ){
    return advise_complete___generic_value( curval, genv, lenv, obj, obj_prefix SUBSEP option_id SUBSEP "\"#" arg_nth "\"")
}

# Just tell me the arguments
function advise_complete_argument_value( curval, genv, lenv, obj, obj_prefix, nth, _candidate_code,      _kp ){

    _kp = obj_prefix SUBSEP "\"#" nth "\""
    if (obj[ _kp ] != "") {
        return advise_complete___generic_value( curval, genv, lenv, obj, _kp, _candidate_code )
    }

    _kp = obj_prefix SUBSEP "\"#n\""
    if (obj[ _kp ] != "") {
        return advise_complete___generic_value( curval, genv, lenv, obj, _kp, _candidate_code )
    }

    return advise_complete___generic_value( curval, genv, lenv, obj, obj_prefix )
}

# Most complicated #1
function advise_complete_option_name_or_argument_value( curval, genv, lenv, obj, obj_prefix,        _option_id, i, j, k, v, _arrl, _desc, _arr_valuel, _arr_value, _required_options ){
    # if ( curval ~ /^--/ ) {
    #     _arrl = obj[ obj_prefix L ]
    #     CODE = CODE "\n" "candidate_arr=(" "\n"
    #     for (i=1; i<=_arrl; ++i) {
    #         _option_id = obj[ obj_prefix, i ]
    #         _desc = ( ZSHVERSION != "" ) ? juq(obj[ obj_prefix SUBSEP _option_id SUBSEP "\"#desc\"" ]) : ""
    #         _arr_valuel = split( juq(_option_id), _arr_value, "|" )
    #         for ( j=1; j<=_arr_valuel; ++j) {
    #             v = _arr_value[j]
    #             if ((v ~ curval) && (lenv[ _option_id ] == "")) {
    #                 if ( _desc != "" ) CODE = CODE jqu(v ":" _desc) "\n"
    #                 else CODE = CODE jqu(v) "\n"
    #             }
    #         }
    #     }
    #     CODE = CODE ")"
    #     return CODE
    # }

    # if ( curval ~ /^-/ ) {
    #     CODE = CODE "\n" "candidate_arr=(" "\n"
    #     _arrl = obj[ obj_prefix L ]
    #     for (i=1; i<=_arrl; ++i) {
    #         _option_id = obj[ obj_prefix, i ]
    #         _desc = ( ZSHVERSION != "" ) ? juq(obj[ obj_prefix SUBSEP _option_id SUBSEP "\"#desc\"" ]) : ""
    #         _arr_valuel = split( juq( _option_id ), _arr_value, "|" )
    #         for ( j=1; j<=_arr_valuel; ++j) {
    #             v = _arr_value[j]
    #             if ((v ~ "--") || ( v !~ "^-")) continue
    #             if ((v ~ curval) && (lenv[ _option_id ] == "")) {
    #                 if ( _desc != "" ) CODE = CODE jqu(v ":" _desc) "\n"
    #                 else CODE = CODE jqu(v) "\n"
    #             }
    #         }
    #     }
    #     # CODE = CODE advise_get_candidate_code( curval, genv, lenv, obj, obj_prefix )
    #     CODE = CODE ")"
    #     return CODE
    # }
    _candidate_code = advise_get_candidate_code( curval, genv, lenv, obj, obj_prefix )

    if ( ( curval == "" ) || ( curval ~ /^-/ ) || (aobj_option_all_set( lenv, obj, obj_prefix ))) {
        return advise_complete_argument_value( curval, genv, lenv, obj, obj_prefix, 1, _candidate_code)
    }

    l = obj[ obj_prefix L ]
    for (i=1; i<=l; ++i) {
        k = obj[ obj_prefix, i ]
        if (k ~ "^\"[^-]") continue
        if ( aobj_istrue(obj, obj_prefix SUBSEP k SUBSEP "\"#subcmd\"" ) ) continue

        if ( aobj_required(obj, obj_prefix SUBSEP k) ) {
            if ( lenv_table[ k ] == "" ) {
                _required_options = (_required_options == "") ? k : _required_options ", " k
            }
        }
    }
    panic("Required options [ " _required_options " ] should be set")

}
