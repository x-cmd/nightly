BEGIN{
    line_count = 0
    
    printf(UI_CURSOR_SAVE) > "/dev/stderr"
    printf(UI_CURSOR_HIDE) > "/dev/stderr"
}

function ui_cursor_goup_n_line(n){
    return "\033[" n "A"
}

function ui_cursor_godown_n_line(n){
    return "\033[" n "B"
}

function cal_empty_line(line_count, width, 
    i, ret){

    ret = ""
    for (i=1; i<=line_count; i=i+1) {
        ret = ret str_rep(" ", width) "\n"
    }
    return ret
}

BEGIN{
    LAST_OUTPUT_LINE_COUNT = 0
    OUTPUT_LINE_COUNT = 0

    UI_LINEWRAP_DISABLE="\033[?7l"
    UI_LINEWRAP_ENABLE="\033[?7h"
}
function output(text, width, 
    line_arr, line_arr_len, return_text, i, blank_line){
    
    return_text = "" UI_LINEWRAP_DISABLE
    

    line_arr_len = split(text, line_arr, "\n")
    OUTPUT_LINE_COUNT = 0
    blank_line = str_rep(" ", width) "\r"
    for (i=1; i<=line_arr_len; i++) {
        line = line_arr[i]
        return_text = return_text blank_line line "\n"
    }
    OUTPUT_LINE_COUNT=line_arr_len

    if (OUTPUT_LINE_COUNT < LAST_OUTPUT_LINE_COUNT) {
        return_text = return_text cal_empty_line(LAST_OUTPUT_LINE_COUNT - OUTPUT_LINE_COUNT, width)
    }

    return_text = return_text UI_LINEWRAP_ENABLE

    return return_text
}

BEGIN {
    output_test = ""
    last_output_test = ""
}

function update(text, width){
    # printf(UI_CURSOR_RESTORE)
    # printf(UI_CURSOR_SAVE)
    # printf "\033[%sA"

    LAST_OUTPUT_LINE_COUNT = OUTPUT_LINE_COUNT

    last_output_test = output_text
    
    output_text = output(text, width)

    printf(UI_CURSOR_RESTORE) > "/dev/stderr"
    # printf(UI_CURSOR_SAVE)

    if (LAST_OUTPUT_LINE_COUNT < OUTPUT_LINE_COUNT) {
        # printf( "%s", 
        #     last_output_test cal_empty_line(OUTPUT_LINE_COUNT - LAST_OUTPUT_LINE_COUNT, width) )
        printf( "%s", str_rep("\n", OUTPUT_LINE_COUNT)) > "/dev/stderr"
        printf("\033[" (OUTPUT_LINE_COUNT ) "A") > "/dev/stderr"
        printf(UI_CURSOR_SAVE) > "/dev/stderr"
    }

    printf("%s", output_text) > "/dev/stderr"
}

BEGIN{
   LAST_WIDTH=0 

   ALREAD_END = 0
}

function end(){
    if (ALREAD_END == 1) return
    ALREAD_END = 1
    printf(UI_CURSOR_RESTORE) > "/dev/stderr"
    printf( "%s", cal_empty_line(LAST_OUTPUT_LINE_COUNT, LAST_WIDTH)) > "/dev/stderr"
    printf(UI_CURSOR_RESTORE) > "/dev/stderr"

    printf(UI_CURSOR_NORM) > "/dev/stderr"
}

{
    if (op == "UPDATE") {
        op = ""
        gsub("\001", "\n", $0)
        LAST_WIDTH=op2
        update($0, op2)
    } else if ($1 == "UPDATE") {
        op = $1
        op2 = $2
    } else if (op == "STDOUT") {
        print $0
    } else if (op == "RESULT") {
        end()
        print $0
    }  else {   
        op = $1
        op2 = $2
    }

}

END {
    end()
}
