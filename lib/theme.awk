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
    TH_HELP                             =       UI_FG_GREEN

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
    TH_QA_Q                         =       UI_FG_YELLOW

    TH_QA_Q_FOCUSED   =  UI_FG_CYAN
    TH_QA_Q_UNFOCUSED =  UI_END

    TH_QA_A_FOCUSED_SELECTED                   =       UI_TEXT_REV UI_FG_CYAN
    TH_QA_A_FOCUSED_NOTSELECTED                =       UI_TEXT_DIM UI_FG_CYAN
    TH_QA_A_UNFOCUSED_SELECTED                 =       UI_TEXT_UNDERLINE UI_FG_CYAN
    TH_QA_A_UNFOCUSED_NOTSELECTED              =       UI_END

    TH_QA_A_FOCUSED_VALID             = ""
    TH_QA_A_FOCUSED_INVALID           = ""
    TH_QA_A_UNFOCUSED_VALID          = ""
    TH_QA_A_UNFOCUSED_INVALID        = ""
    # EndSection

    # Section: table
    # TH_TABLE_HEADER_BG                  =       ""
    # TH_TABLE_HEADER_ITEM                =       ""
    TH_TABLE_HEADER_ITEM_NORMAL         =       UI_TEXT_UNDERLINE UI_TEXT_BOLD
    TH_TABLE_LINE_ITEM_FOCUSED          =       UI_TEXT_BOLD
    TH_TABLE_SELECTED_COL               =       UI_FG_BLUE UI_TEXT_REV
    TH_TABLE_SELECTED_ROW               =       UI_FG_GREEN UI_TEXT_REV
    # EndSection

    # Find item
    TH_TABLE_LINE_ITEM_HIGHLIGHT_0      =       ""
    TH_TABLE_LINE_ITEM_HIGHLIGHT_1      =       UI_END

    # Section: select
    TH_SELECT_HEADER_NORMAL           =       UI_FG_CYAN
    TH_SELECT_ITEM_FOCUSED            =       UI_FG_GREEN UI_TEXT_REV
    TH_SELECT_ITEM_SELECTED           =       UI_FG_GREEN
    # EndSection

    # help panel

    # Status line   # ...
    TH_STATUSLINE_BG                    =       UI_FG_BLUE
    TH_STATUSLINE_BG_FOCUSED            =       UI_FG_CYAN
    TH_STATUSLINE_TEXT                  =       UI_NORMAL
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


# Section: statusline help
function th_statusline_text( text ){
    return TH_STATUSLINE_TEXT text UI_END
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
