# Section: NR==1    DATA SOURCE parsing
BEGIN {
    S = "\001"

    ATT_DESC    = "\003"
    ATT_VAR     = "\004"

    ATT_DEFAULT = "\005"
    ATT_OP      = "\006"
    ATT_OP_L    = "\007"

    ATT_ANS     = "\010"

    FS="\001"
}

NR==1{
    if (RS == "\n") {
        gsub("\001", "\n", $0)
    }
    # TODO: in some case. There is a bug
    argl = split($0, args, "\002")

    rulel = 0
    for (i=1; i<=argl; ++i) {
        rulel = rulel + 1
        # printf("===>" i ": %s\n", args[i]) >"/dev/stderr"
        rule[ rulel ATT_DESC ]              = args[i]
        rule[ rulel ATT_VAR ]               = args[i+1]
        rule[ rulel ATT_DEFAULT ]           = args[i+2]
        if (args[i+3] == "--") {
            i=i+3
            rule[ rulel ATT_OP ] = ""
            continue
        }

        rule[ rulel ATT_OP ] = args[i+3]
        # printf(i+1 ": %s\n", args[i+1]) >"/dev/stderr"
        # printf(i+2 ": %s\n", args[i+2]) >"/dev/stderr"
        # printf("op: > " i+3 ": %s\n", args[i+3]) >"/dev/stderr"

        i = i + 4
        for (j=i; j<=argl; ++j) {
            if (args[j] == "--") break
            rule[ rulel ATT_OP (j-i+1) ] = args[j]
        }
        rule[ rulel ATT_OP_L ] = j-i
        i=j
    }

    for (i=1; i<=rulel; ++i) {
        question            = rule[ i ATT_DESC ]
        if ( rule[ i ATT_OP ] != "=" ) {
            ctrl_lineedit_init( rule, i ATT_ANS  )
            ctrl_lineedit_put(  rule, rule[ i ATT_DEFAULT ], i ATT_ANS )
        } else {
            ctrl_rstate_init( rule, 1, rule[ i ATT_OP_L ], i ATT_ANS )
            tmp = rule[ i ATT_DEFAULT ]
            if ( tmp == "" ) continue
            for (j=1; j<=rule[ i ATT_OP_L ]; ++j){
                if ( tmp == rule[ i ATT_OP j ]) {
                    ctrl_rstate_set( rule, j, i ATT_ANS )
                    break
                }
            }
        }
    }

    ctrl_rstate_init( CURRENT, 1, rulel+1 )
}
# EndSection

# Section: ctrl
BEGIN {
    if (exit_strategy == "")  exit_strategy = "execute|save|exit"
    exit_strategy_arrl = split(exit_strategy, exit_strategy_arr, "|")

    ctrl_exit_strategy =  ctrl_rstate_init( EXIT, 1, exit_strategy_arrl )
}

function ctrl( char_type, char_value,                   _ctrl_current ) {
    if (char_value == "UP")             return ctrl_rstate_dec( CURRENT )
    if (char_value == "DN")             return ctrl_rstate_inc( CURRENT )

    _ctrl_current = ctrl_rstate_get( CURRENT )
    if (_ctrl_current == rulel + 1) {
        if (char_value == "ENTER")      exit(0)
        if (char_value == "LEFT")       return ctrl_rstate_dec( EXIT )
        if (char_value == "RIGHT")      return ctrl_rstate_inc( EXIT )
    } else {
        if (char_value == "ENTER")      return ctrl_rstate_inc( CURRENT )       # _ctrl_current != rule + 1
        if (rule[ _ctrl_current ATT_OP ] == "="){
            if (char_value == "LEFT")       return ctrl_rstate_dec( rule, _ctrl_current ATT_ANS )
            if (char_value == "RIGHT")      return ctrl_rstate_inc( rule, _ctrl_current ATT_ANS )
        } else{
            ctrl_lineedit_handle(  rule, _ctrl_current ATT_ANS, char_type, char_value )
        }
    }
}

# EndSection

# Section: view
function view(            _ctrl_current, _component_help, _component_body, _component_exit  ){
    _ctrl_current = ctrl_rstate_get( CURRENT )

    _component_help = view_help( _ctrl_current )
    _component_body = view_body( _ctrl_current )
    _component_exit = view_exit( _ctrl_current )

    send_update(  _component_help "\n" _component_body "\n\n" _component_exit "\n"  )
}

function view_help( _ctrl_current, data ){
    data = "Press <Arrow-Up> and <Arrow-Down> to alternate question" "\n"
    if (rule[ _ctrl_current ATT_OP ] == "=") {
        data = data "Press <Arrow-Left> and <Arrow-Right> to alternative choice, or input digit."
    }
    return th_help_text( data "\n" )
}

function view_body( _ctrl_current,                          question_width, data, _question, _line, _tmp, _is_focused, _is_selected,  i, j ){
    question_width = 30
    for (i=1; i<=rulel; ++i) {
        _question       =  sprintf( "%-" question_width "s",   rule[ i ATT_DESC ] )
        _is_focused     =  _ctrl_current == i

        if ( _is_focused ) {
            STYLE_ANSWER_SELECTED       = TH_QA_A_FOCUSED_SELECTED
            STYLE_ANSWER_UNSELECTED     = TH_QA_A_FOCUSED_NOTSELECTED
            _line                       = th( TH_QA_Q_FOCUSED,   _question ) " "
        } else {
            STYLE_ANSWER_SELECTED       = TH_QA_A_UNFOCUSED_SELECTED
            STYLE_ANSWER_UNSELECTED     = TH_QA_A_UNFOCUSED_NOTSELECTED
            _line                       = th( TH_QA_Q_UNFOCUSED,   _question ) " "
        }

        op = rule[ i ATT_OP ]
        if (op != "=") {
            _answer     = ctrl_lineedit_get( rule, i ATT_ANS )
            _answer     = (op !~ /\*/) ? _answer : ui_str_rep( "*", length(_answer) )
            _line       = _line th( "", _answer)
        } else {
            _answer     = ctrl_rstate_get( rule, i ATT_ANS )
            for (j=1; j<=rule[ i ATT_OP_L ]; ++j) {
                # TODO: if it is too long, use multiple line
                _is_selected    = _answer == j
                _line           = _line th( _is_selected ? STYLE_ANSWER_SELECTED: STYLE_ANSWER_UNSELECTED, rule[ i ATT_OP j ] ) " "
            }
        }
        data = data "\n" _line
    }
    return data
}

BEGIN{
    CLR_DESC = "\033[0;32m"
    CLR_EXIT_ANSWER     = "\033[34m"
    CLR_EXIT_ANSWER_SEL = "\033[33m"
}

# I don't know ... It has not been well-designed yet.
function view_exit( _ctrl_current,  data,           _is_focused, _is_selected ){
    _is_focused = _ctrl_current == rulel+1
    if ( _is_focused ) {
        data = "\033[36m"
        STYLE_EXIT      = "\033[7m" CLR_EXIT_ANSWER
        STYLE_EXIT_NOT  = CLR_EXIT_ANSWER
    } else {
        data = ""
        STYLE_EXIT      = "\033[7m" CLR_EXIT_ANSWER_SEL
        STYLE_EXIT_NOT  = CLR_EXIT_ANSWER_SEL
    }
    _ctrl_exit_strategy = ctrl_rstate_get( EXIT )
    for (i=1; i<=exit_strategy_arrl; ++i) {
        _is_selected    = _ctrl_exit_strategy == i
        data            = data "   " th( _is_selected ? STYLE_EXIT : STYLE_EXIT_NOT,    exit_strategy_arr[i] )
    }
    return data
}

# EndSection

# Section: NR>1     command stream and end
NR>1{
    if ( try_update_width_height( $0 ) ) {
        view()
    } else {
        cmd=$0
        gsub(/^C:/, "", cmd)
        idx = index(cmd, ":")
        ctrl(substr(cmd, 1, idx-1), substr(cmd, idx+1))
    }
}

END {
    for (i=1; i<=rulel; ++i) {
        var =       rule[ i ATT_VAR ]
        if (rule[ i ATT_OP ] == "=")    _answer = rule[ i ATT_OP ctrl_rstate_get( rule, i ATT_ANS ) ]
        else                            _answer = ctrl_lineedit_get( rule, i ATT_ANS )
        send_env( var, _answer )
    }
    send_env("___X_CMD_UI_FORM_EXIT", exit_strategy_arr[ ctrl_rstate_get( EXIT ) ])
}
# EndSection
