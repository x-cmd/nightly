
# Section: view
BEGIN {
    ctrl_help_item_put("ARROW UP/DOWN/LEFT/ROW", "to move focus")
    ctrl_help_item_put("ENTER", "for enter")
}

function view(      _component_help, _component_body){
    view_calcuate_geoinfo()

    _component_help         = view_help()
    _component_select       = view_select()
    _component_preview      = view_preview()

    send_update( _component_help "\n" _component_body "\n" _component_preview  )
}

function view_help(){
    return sprintf("%s", th_help_text( ctrl_help_get() ) )
}

# Using grid select
function view_select(){

}

function view_preview(){
    return
}

# EndSection

# Section: ctrl
function get_view_body_row_size() {
    VIEW_BODY_ROW_SIZE = max_row_size - 10
    if ( VIEW_BODY_ROW_SIZE > MAX_DATA_ROW_NUM )     VIEW_BODY_ROW_SIZE = MAX_DATA_ROW_NUM
    if ( VIEW_BODY_ROW_SIZE < 5)     VIEW_BODY_ROW_SIZE = 5
    return VIEW_BODY_ROW_SIZE
}

function ctrl(char_type, char_value,        _selected, _selected_keypath ){
    exit_if_detected( char_value, ",q,ENTER," )

    if (char_value == "h")                               return ctrl_help_toggle()
    if (char_value == "UP")                              return ctrl_win_rdec( treectrl, cur_keypath )
    if (char_value == "DN")                              return ctrl_win_rinc( treectrl, cur_keypath )

    if ((char_value == "LEFT") && (stack_length( treectrl ) != 1)) {
        stack_pop( treectrl )
        cur_keypath = stack_top( treectrl )
        return
    }

    if (char_value == "RIGHT") {
        _selected = data[ cur_keypath L ctrl_win_val( treectrl, cur_keypath ) ]
        _selected_keypath = cur_keypath S _selected
        if ( data[ _selected_keypath L ] < 1 ) return
        cur_keypath = _selected_keypath
        stack_push( treectrl, cur_keypath )
        return
    }
}

# EndSection

# Section: cmd
BEGIN{
    THEME_ARR_L = 0
    PREVIEW_ARR_L = 0
    get_theme_arr()
}

function get_theme_arr( _cmd, i){
    # tar -t style/ <theme.tgz
    _cmd = "tar t style/ <" THEME_TAR_PATH
    for (i=1; _cmd | getline _line; i++) {

        THEME_ARR[ ++THEME_ARR_L ] = substr(_line, 6)
    }
}

function get_theme_preview( theme, _cmd, i, c){
    c = PREVIEW[theme]
    if ( c == "" ) {
        # tar -O -x style-preview/ys  <theme.tgz
        _cmd = "tar -O -x " " " "style-preview/" theme " < " THEME_TAR_PATH
        for (i=1; _cmd | getline _line; i++) {
            c = c "\n" _line
        }

        PREVIEW[theme] = c
    }
    return c
}
# EndSection

# Section: cmd source
NR==1{
    try_update_width_height( $0 )
    view()
}

NR>1{
    if ( try_update_width_height( $0 ) )    next
    # TODO: if it is update, recalculate the view.

    _cmd=$0
    gsub(/^C:/, "", _cmd)
    idx = index(_cmd, ":")
    ctrl(substr(_cmd, 1, idx-1), substr(_cmd, idx+1))
    view()
}
# EndSection


END {
    if ( exit_is_with_cmd() == true ) {
        _selected = data[ cur_keypath L ctrl_win_val( treectrl, cur_keypath ) ]
        _selected_keypath = cur_keypath S _selected
        send_env( "___X_CMD_THEME_FINAL_COMMAND",    exit_get_cmd() )
        send_env( "___X_CMD_THEME_CURRENT_ITEM",  _selected_keypath )
    }
}
