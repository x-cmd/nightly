
# Section: view

BEGIN {
    ctrl_help_item_put("ARROW UP/DOWN/LEFT/ROW", "to move focus")
    ctrl_help_item_put("ENTER", "for enter")
}

function view_help(){
    return sprintf("%s", th_help_text( ctrl_help_get() ) )
}
function view_header(){
    return sprintf("%s", th(TH_SELECTN_HEADER_NORMAL, data_header) )
}

function view_body(         i, j, _i_for_this_column, _offset_for_this_column, _selected_index_of_this_column, _max_column_size, _tmp, _data ){
    for (j=WIN_BEGIN; j<=WIN_END; ++j) {
        _offset_for_this_column = ctrl_win_begin( data, j )
        _max_column_size = data[ j S ] + 3
        _selected_index_of_this_column = ctrl_win_val( data, j )

        for (i=1; i<=VIEW_BODY_ROW_SIZE; ++i) {
            _i_for_this_column = _offset_for_this_column + i - 1
            if ( _i_for_this_column <= data[ j L ] ) _tmp = str_pad_right(data[ j L _i_for_this_column ], _max_column_size)
            else _tmp = ui_str_rep(" ", _max_column_size)
            if (j == FOCUS_COL) {
                STYLE_SELECTN_SELECTED      =   TH_SELECTN_ITEM_FOCUSED_SELECT
                STYLE_SELECTN_UNSELECTED    =   TH_SELECTN_ITEM_FOCUSED_UNSELECT
            } else {
                STYLE_SELECTN_SELECTED      =   TH_SELECTN_ITEM_UNFOCUSED_SELECT
                STYLE_SELECTN_UNSELECTED    =   TH_SELECTN_ITEM_UNFOCUSED_UNSELECT
            }
            if ( _selected_index_of_this_column == _i_for_this_column ) _tmp = th(STYLE_SELECTN_SELECTED, _tmp)
            else _tmp = th(STYLE_SELECTN_UNSELECTED, _tmp)
            _data[ i ] = _data[ i ] _tmp
        }
    }

    _tmp = ""
    for (i=1; i<=VIEW_BODY_ROW_SIZE; ++i) _tmp = _tmp UI_END "\n" "  " _data[ i ]
    return _tmp
}

function view_calcuate_geoinfo(){
    if ( VIEW_BODY_ROW_SIZE >= MAX_DATA_ROW_NUM ) return
    if ( ctrl_help_toggle_state() == true ) {
        VIEW_BODY_ROW_SIZE = max_row_size - 9 -1
    } else {
        VIEW_BODY_ROW_SIZE = max_row_size - 8 -1
    }
}

function view(      _component_help, _component_header, _component_body){
    view_calcuate_geoinfo()

    _component_help         = view_help()
    _component_body         = view_body()

    send_update( _component_help "\n" _component_body  )
}

# EndSection

# Section: ctrl
function calculate_offset_from_end( end,       i, s, t ){
    # if (end == "")  end = MAX_DATA_COL_NUM
    s = 0
    for (i=end; i>=1; --i) {
        s += data[ i S ] + 3 # 3 is column width
        if (s > max_col_size) return i+1
    }
    return 1
}


function ctrl_cal_colwinsize_by_focus( col,            _selected_keypath ){
    if (data[ col L ] <= 0) {
        WIN_END = col - 1
    } else {
        WIN_END = col
    }
    # WIN_END = col
    # WIN_BEGIN might be WIN_END + 1
    WIN_BEGIN = calculate_offset_from_end( WIN_END )
}

function ctrl(char_type, char_value){
    EXIT_CHAR_LIST = ",q,ENTER,"
    exit_if_detected( char_value )

    if (char_value == "UP")  {
        ctrl_win_rdec( data, FOCUS_COL )
        return ctrl_cal_colwinsize_by_focus( FOCUS_COL )
    }
    if (char_value == "DN") {
        ctrl_win_rinc( data, FOCUS_COL )
        return ctrl_cal_colwinsize_by_focus( FOCUS_COL )
    }

    if (char_value == "LEFT" )  {
        if (FOCUS_COL == 1)     return
        -- FOCUS_COL
        return ctrl_cal_colwinsize_by_focus( FOCUS_COL )
    }

    if (char_value == "RIGHT") {
        if (FOCUS_COL >= input_level) return
        ++ FOCUS_COL
        return ctrl_cal_colwinsize_by_focus( FOCUS_COL )
    }
    if (char_value == "h")      return ctrl_help_toggle()
}

# EndSection

# Section: cmd source
# update

BEGIN{
    INPUT_STATE_DATA = 0
    INPUT_STATE_CTRL = 1
    input_state = INPUT_STATE_CTRL
    FOCUS_COL=1
}

function reinit_selected_index( col ) {
    # TODO: 10 reserve space
    VIEW_BODY_ROW_SIZE = max_row_size - 10
    if ( VIEW_BODY_ROW_SIZE > MAX_DATA_ROW_NUM )     VIEW_BODY_ROW_SIZE = MAX_DATA_ROW_NUM
    l = data[ col L ]
    if ( l == 0 ) return
    ctrl_win_init( data, col, 1, l, VIEW_BODY_ROW_SIZE)
}

function consume_ctrl(){
    if ($0 == "---") return
    if ($1 == "---") {
        input_level = $2
        data[ input_level L ] = ($3 == -1) ? -1 : 0
        ctrl_win_set(data, 1, input_level)
        _maxcollen[ input_level ] = 0
        input_state = INPUT_STATE_DATA
    } else if (try_update_width_height( $0 ) == true) {
        return
    } else {
        _cmd=$0
        gsub(/^C:/, "", _cmd)
        idx = index(_cmd, ":")
        ctrl(substr(_cmd, 1, idx-1), substr(_cmd, idx+1))
        view()
    }
}

function consume_data(){
    if ($0 == "---") {
        data[ input_level S ] = _maxcollen[ input_level ]
        input_state = INPUT_STATE_CTRL
        ctrl_cal_colwinsize_by_focus( input_level )
        reinit_selected_index( input_level )
        view()
        return
    } else {
        l = data[ input_level L ] + 1
        data[ input_level L ] = l
        if (l > MAX_DATA_ROW_NUM)   MAX_DATA_ROW_NUM = l
        if (_maxcollen[ input_level ] < $1)  _maxcollen[ input_level ] = $1
        data[ input_level L l ] = substr($0, length($1)+1)
    }
}

input_state==INPUT_STATE_DATA{
    consume_data()
}

input_state==INPUT_STATE_CTRL{
    consume_ctrl()
}
# EndSection

END {
    if ( exit_is_with_cmd() == true ) {
        for (i=1; i<input_level; i++) {
            _key_path = _key_path L data[ i L ctrl_win_val( data, i ) ]
        }
        send_env( "___X_CMD_UI_SELECTN_FINAL_COMMAND",    exit_get_cmd() )
        send_env( "___X_CMD_UI_SELECTN_CURRENT_ITEM",         _key_path )
    }
}

