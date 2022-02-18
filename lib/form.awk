
# Section: NR==1 parsing
BEGIN {
    S = "\001"

    rulel       = 1

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
        if (rule[ i ATT_OP ] == "=" && rule[ i ATT_DEFAULT ] == "") {
            rule[ i ATT_DEFAULT ] = 1
        }
        rule[ i ATT_ANS ]   = rule[ i ATT_DEFAULT ]
        op                  = rule[ i ATT_OP ]
        # printf("%-30s%-20s\n", question, op) >"/dev/stderr"
    }
}
# EndSection

# Section: ctrl
BEGIN {
    ctrl_current = 1
    if (exit_strategy == "")  exit_strategy = "execute|save|exit"
    exit_strategy_arrl = split(exit_strategy, exit_strategy_arr, "|")

    ctrl_exit_strategy = 1
}

function ctrl(type, char) {
    if (char == "UP") {
        ctrl_current -= 1
        if (ctrl_current == 0) ctrl_current = rulel
        return
    }

    if (char == "DN") {
        ctrl_current += 1
        if (ctrl_current > rulel+1) ctrl_current = 1
        return
    }

    if (ctrl_current == rulel + 1) {
        if (char == "LEFT") {
            ctrl_exit_strategy -= 1
            if (ctrl_exit_strategy == 0) ctrl_exit_strategy = exit_strategy_arrl
            return
        }

        if (char == "RIGHT") {
            ctrl_exit_strategy += 1
            if (ctrl_exit_strategy == exit_strategy_arrl+1) ctrl_exit_strategy = 1
            return
        }

        if (char == "ENTER") {
            exit(0)
        }
        return
    }

    if (char == "ENTER") {
        ctrl_current += 1
        if (ctrl_current > rulel+1) ctrl_current = 1
        return
    }

    if (char == "DELETE") {
        answer = rule[ ctrl_current ATT_ANS ]
        if (answer != "")  answer = substr(answer, 1, length(answer)-1)
        rule[ ctrl_current ATT_ANS ] = answer
        return
    }

    if (char == "") return

    answer = rule[ ctrl_current ATT_ANS ]
    op = rule[ ctrl_current ATT_OP ]

    if (op == "=") {

        if (char == "LEFT") {
            answer -= 1
            if (answer <= 0) answer = rule[ ctrl_current ATT_OP_L ]
            rule[ ctrl_current ATT_ANS ] = answer
            return
        }

        if (char == "RIGHT") {
            answer += 1
            if (answer > rule[ ctrl_current ATT_OP_L ]) answer = 1
            rule[ ctrl_current ATT_ANS ] = answer
            return
        }

        if (type ~ /^ascii-digit/) {
            answer = answer char
            rule[ ctrl_current ATT_ANS ] = answer
            return
        }
        return
    }

    if (type ~ /^(ascii-space)|(UTF8)|(ascii-digit)|(ascii-letter)|(ascii-symbol)/) {
        answer = answer char
        rule[ ctrl_current ATT_ANS ] = answer
    }
}
# EndSection

# Section: view
BEGIN{
    CLR_DESC = "\033[0;32m"

    CLR_EXIT_ANSWER     = "\033[34m"
    CLR_EXIT_ANSWER_SEL = "\033[33m"
}

function draw_secret_text(text,       _i,_ret){
    _ret=""
    for (_i=1; _i<=length(text); ++_i){
        _ret=_ret "*"
    }
    return _ret
}

function view(  msg){
    if (rule[ ctrl_current ATT_OP ] == "=") {
        msg = "Press <Arrow-Up> and <Arrow-Down> to alternate question" "\n"
        msg = msg "Press <Arrow-Left> and <Arrow-Right> to alternative choice, or input digit."
    } else {
        msg = "Press <Arrow-Up> and <Arrow-Down> to alternate question" "\n"
    }

    content = CLR_DESC msg "\n" "\033[0m"

    question_width = -30

    for (i=1; i<=rulel; ++i) {
        question =  rule[ i ATT_DESC ]
        answer =    rule[ i ATT_ANS ]
        op =        rule[ i ATT_OP ]

        if ( ctrl_current == i ) {
            STYLE_ANSWER_NOT    = "\033[0;7;33m"
            STYLE_ANSWER        = "\033[0;2;33m"
            CLR_QUESTION        = "\033[7;33m"
        } else {
            STYLE_ANSWER_NOT    = "\033[0;2;34m"
            STYLE_ANSWER        = "\033[1;34m"
            CLR_QUESTION        = "\033[0;33m"
        }

        data = sprintf(CLR_QUESTION "%" question_width "s", question)   "\033[0m" ": "
        if (op != "=") {
            data = data ( (op ~ "*") ? draw_secret_text(answer) : answer ) "\033[0m"
        } else {
            for (j=1; j<=rule[ i ATT_OP_L ]; ++j) {
                # TODO: if it is too long, use multiple line
                data = data ( (answer == j) ? STYLE_ANSWER_NOT : STYLE_ANSWER )    rule[ i ATT_OP j ]  "\033[0m "
            }
        }

        content = content "\n" data
    }

    if (ctrl_current == rulel+1) {
        data = "\033[0;36m"
        STYLE_EXIT        = "\033[7m" CLR_EXIT_ANSWER
        STYLE_EXIT_NOT    = CLR_EXIT_ANSWER
    } else {
        data = "\033[0m"
        STYLE_EXIT        = "\033[7m" CLR_EXIT_ANSWER_SEL
        STYLE_EXIT_NOT    = CLR_EXIT_ANSWER_SEL
    }

    for (i=1; i<=exit_strategy_arrl; ++i) {
        data = data "   "   ( (ctrl_exit_strategy == i) ? STYLE_EXIT : STYLE_EXIT_NOT )   exit_strategy_arr[i] "\033[0m"
    }

    content = content "\n\n" data "\n"
    # printf("%s", content) >"/dev/stderr"
    send_update(content)
}
# EndSection

NR>1{
    # printf("%s", $0) >"/dev/stderr"
    if ($0~/^R:/) {
        split($0, arr, ":")
        max_col_size = arr[3]
        max_row_size = arr[4]
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
        # answer = rule[ i ATT_ANS ]
        if (rule[ i ATT_OP ] == "="){
            answer = rule[ i ATT_OP rule[ i ATT_ANS ] ]
        } else{
            answer = rule[ i ATT_ANS ]
        }
        send_env(var, answer)
    }
    send_env("___X_CMD_UI_FORM_EXIT", exit_strategy_arr[ctrl_exit_strategy])
}
