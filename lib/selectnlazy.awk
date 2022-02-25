
# Section: view

BEGIN {
    ctrl_help_item_put("ARROW UP/DOWN/LEFT/ROW", "to move focus")
    ctrl_help_item_put("ENTER", "for enter")
}

function view_help(){
    return sprintf("%s\n", th_help_text( ctrl_help_get() ) )
}
function view_header(){
    return sprintf("%s", th(TH_SELECTN_HEADER_NORMAL, data_header) )
}

function view_body(         i, j, _key_fa, data, _i_for_this_column, _offset_for_this_column, _selected_index_of_this_column, _value_of_this_column, _max_column_size, _tmp, _data ){
    for (j=WIN_BEGIN; j<=WIN_END; ++j) {
        _key_fa = SELECTED_KEYPATH_STACK[ j-1 ]
        _offset_for_this_column = ctrl_win_begin( SELECTED_IDX, _key_fa )
        _max_column_size = data_maxcollen(j) + 3

        _selected_index_of_this_column = ctrl_win_val( SELECTED_IDX, _key_fa )

        for (i=1; i<=VIEW_BODY_ROW_SIZE; ++i) {
            _i_for_this_column = _offset_for_this_column + i - 1
            _tmp = str_pad_right( DATA[ _key_fa L _i_for_this_column ], _max_column_size )
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
    if ( VIEW_BODY_ROW_SIZE > MAX_DATA_ROW_NUM ) return
    if ( ctrl_help_toggle_state() == true ) {
        VIEW_BODY_ROW_SIZE = max_row_size - 9
    } else {
        VIEW_BODY_ROW_SIZE = max_row_size - 8
    }
}

function view(      _component_help, _component_header, _component_body){
    if (DATA_HAS_CHANGED == false)    return
    DATA_HAS_CHANGED = false
    view_calcuate_geoinfo()

    _component_help         = view_help()
    _component_header       = view_header()
    _component_body         = view_body()

    send_update( _component_help "\n" _component_header  _component_body  )
}

# EndSection

# Section: ctrl
function calculate_offset_from_end( end,       i, s, t ){
    # if (end == "")  end = MAX_DATA_COL_NUM
    s = 0
    for (i=end; i>=1; --i) {
        s += data_maxcollen(i) + 3 # 3 is column width
        if (s > max_col_size) return i+1
    }
    return 1
}


function ctrl_cal_colwinsize_by_focus( col,            _selected_keypath ){
    #
    if (DATA[ FOCUS_COL L ] >= 0) {
        WIN_END = col + 1
    } else {
        WIN_END = col
    }
    # WIN_BEGIN might be WIN_END + 1
    WIN_BEGIN = calculate_offset_from_end( WIN_END )
}

function ctrl(char_type, char_value){
    EXIT_CHAR_LIST = ",q,ENTER,"
    exit_if_detected( char_value )

    if (char_value == "UP")  {
        i = ctrl_win_dec( data, FOCUS_COL )
        d = data[ FOCUS_COL L i ]
        return ctrl_cal_colwinsize_by_focus( FOCUS_COL )
    }
    if (char_value == "DN") {
        i = ctrl_win_inc( data, FOCUS_COL )
        d = data[ FOCUS_COL L i ]
        return ctrl_cal_colwinsize_by_focus( FOCUS_COL )
    }

    if (char_value == "LEFT" )  {
        if (FOCUS_COL == 1)     return
        -- FOCUS_COL
        return ctrl_cal_colwinsize_by_focus( FOCUS_COL )
    }

    if (char_value == "RIGHT") {
        ++ FOCUS_COL
        return ctrl_cal_colwinsize_by_focus( FOCUS_COL )
    }
    if (char_value == "h")                          return ctrl_help_toggle()
}

# EndSection

# Section: cmd source
# update

BEGIN{
    INPUT_STATE_DATA = 0
    INPUT_STATE_CTRL = 1
    input_state = INPUT_STATE_CTRL
}

function data_maxcollen( col ){
    return data[ FOCUS_COL S ]
}

input_state==INPUT_STATE_DATA{
    if ($0 == "---") {
        data[ input_level S ] = _maxcollen
        input_state = INPUT_STATE_CTRL
    } else {
        l = data[ input_level L ] + 1
        data[ input_level L ] = l
        if (_maxcollen < $1) _maxcollen = $1
        data[ input_level L l ] = substr($0, length($1)+1)
    }
}

input_state==INPUT_STATE_CTRL{
    if ($1 == "---") {
        input_level = $2
        data[ input_level L ] = ($3 == -1) ? -1 : 0
        _maxcollen = 0
        input_state = INPUT_STATE_DATA
    } else if (try_update_width_height( $0 ) == true) {
        return
    } else {
        DATA_HAS_CHANGED = true

        _cmd=$0
        gsub(/^C:/, "", _cmd)
        idx = index(_cmd, ":")
        ctrl(substr(_cmd, 1, idx-1), substr(_cmd, idx+1))
        view()
    }

}
# EndSection

