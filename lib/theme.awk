BEGIN {
    TH_SEPERATOR = ""
    TH_INFO = ""
    TH_IMPORTANT = ""
    TH_ERROR = ""
    TH_NOT = ""

    TH_NORMAL_BEGIN = ""

    UI_END = "\033[0m"

    # All Variable Used in ui components will be placed here ...


    # help
    TH_HELP                             =       "\033[0;32m"

    # Section: list item
    TH_LIST_ITEM_NORMAL_0               =       ""
    TH_LIST_ITEM_NORMAL_1               =       UI_END
    TH_LIST_ITEM_SELECTED_0             =       ""
    TH_LIST_ITEM_SELECTED_1             =       UI_END
    TH_LIST_ITEM_FOCUSED_0              =       ""
    TH_LIST_ITEM_FOCUSED_1              =       UI_END
    TH_LIST_ITEM_HIGHLIGHT_0            =       ""
    TH_LIST_ITEM_HIGHLIGHT_1            =       UI_END
    # EndSection

    # Section: question and answer
    TH_QA_Q                         =       "\033[0;33m"

    TH_QA_Q_FOCUSED   = "\033[7;33m"
    TH_QA_Q_UNFOCUSED = "\033[0;33m"

    TH_QA_A_FOCUSED_SELECTED                   =       "\033[0;2;33m"
    TH_QA_A_FOCUSED_NOTSELECTED                =       "\033[0;7;33m"
    TH_QA_A_UNFOCUSED_SELECTED                =       "\033[1;34m"
    TH_QA_A_UNFOCUSED_NOTSELECTED            =       "\033[0;2;34m"

    TH_QA_A_FOCUSED_VALID             = ""
    TH_QA_A_FOCUSED_INVALID           = ""
    TH_QA_A_UNFOCUSED_VALID          = ""
    TH_QA_A_UNFOCUSED_INVALID        = ""
    # EndSection

    # Section: table
    TH_TABLE_HEADER_BG                  =       ""
    TH_TABLE_HEADER_ITEM                =       ""
    TH_TABLE_HEADER_ITEM_NORMAL_0       =       ""
    TH_TABLE_HEADER_ITEM_NORMAL_1       =       UI_END
    TH_TABLE_HEADER_ITEM_SELECTED_0     =       ""
    TH_TABLE_HEADER_ITEM_SELECTED_1     =       UI_END
    TH_TABLE_HEADER_ITEM_FOCUSED_0        =       ""
    TH_TABLE_HEADER_ITEM_FOCUSED_1        =       UI_END

    TH_TABLE_LINE_ITEM                  =       ""
    TH_TABLE_LINE_ITEM_NORMAL_0         =       ""
    TH_TABLE_LINE_ITEM_NORMAL_1         =       UI_END
    TH_TABLE_LINE_ITEM_SELECTED_0       =       ""
    TH_TABLE_LINE_ITEM_SELECTED_1       =       UI_END
    TH_TABLE_LINE_ITEM_FOCUSED_0          =       ""
    TH_TABLE_LINE_ITEM_FOCUSED_1          =       UI_END
    # EndSection

    # Find item
    TH_TABLE_LINE_ITEM_HIGHLIGHT_0      =       ""
    TH_TABLE_LINE_ITEM_HIGHLIGHT_1      =       UI_END

    # help panel

    # Status line   # ...
    TH_STATUSLINE_BG                    =       UI_FG_BLUE
    TH_STATUSLINE_BG_FOCUSED              =       UI_FG_CYAN
    TH_STATUSLINE_TEXT_0                =       UI_NORMAL
    TH_STATUSLINE_TEXT_1                =       UI_END
}

function th( style, text ){
    return style text UI_END
}

# Section: list-item
function th_list_item_normal(text){
    return TH_LIST_ITEM_NORMAL_0 text TH_LIST_ITEM_NORMAL_1
}

function th_list_item_selected(text){
    return TH_LIST_ITEM_SELECTED_0 text TH_LIST_ITEM_SELECTED_1
}

function th_list_item_FOCUSED(text){
    return TH_LIST_ITEM_FOCUSED_0 text TH_LIST_ITEM_FOCUSED_1
}

function th_list_item_highlight(text){
    return TH_LIST_ITEM_FOCUSED_0 text TH_LIST_ITEM_FOCUSED_1
}
# EndSection

# Section: table-header-item
function th_table_header_item_normal(text){
    return TH_TABLE_HEADER_ITEM_NORMAL_0 text TH_TABLE_HEADER_ITEM_NORMAL_1
}

function th_table_header_item_selected(text){
    return TH_TABLE_HEADER_ITEM_SELECTED_0 text TH_TABLE_HEADER_ITEM_SELECTED_1
}

function th_table_header_item_FOCUSED(text){
    return TH_TABLE_HEADER_ITEM_FOCUSED_0 text TH_TABLE_HEADER_ITEM_FOCUSED_1
}

function th_table_header_item_highlight(text){
    return TH_TABLE_HEADER_ITEM_FOCUSED_0 text TH_TABLE_HEADER_ITEM_FOCUSED_1
}
# EndSection

# Section: table-line-item
function th_table_line_item_normal(text){
    return TH_TABLE_HEADER_ITEM_NORMAL_0 text TH_TABLE_HEADER_ITEM_NORMAL_1
}

function th_table_line_item_selected(text){
    return TH_TABLE_HEADER_ITEM_SELECTED_0 text TH_TABLE_HEADER_ITEM_SELECTED_1
}

function th_table_line_item_FOCUSED(text){
    return TH_TABLE_HEADER_ITEM_FOCUSED_0 text TH_TABLE_HEADER_ITEM_FOCUSED_1
}

function th_table_line_item_highlight(text){
    return TH_TABLE_HEADER_ITEM_FOCUSED_0 text TH_TABLE_HEADER_ITEM_FOCUSED_1
}

# EndSection

# Section: statusline help
function th_statusline_text( text ){
    return TH_STATUSLINE_TEXT_0 text TH_STATUSLINE_TEXT_1
}

function th_help_text( text ){
    return TH_HELP text UI_END
}

# EndSection

# Section: qa
function th_qa_answer_valid( text ){
    return TH_ANSWER_VALID text UI_END
}

function th_qa_answer_invalid( text ){
    return TH_ANSWER_INVALID text UI_END
}

function th_qa_answer( text ){
    return TH_ANSWER text UI_END
}


# EndSection
