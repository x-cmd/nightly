
# Section: Global data
BEGIN {
    KSEP = "\001"

    if (available_cols_len == "")       available_cols_len = 30

    if (available_row == "")            available_row = 10
    max_row_in_page = available_row

    start_row = 1

    # CURRENT_COLUMN = 1

    table_col = 0

    max_col_size = -1
    max_row_size = -1

    # data
    # data_wlen
    # data_highlight
    # col_max
}
# EndSection

# Section: view
function update_view_print_cell(logic_row_i, row_i, col_i,       h, _size){
    cord = row_i KSEP col_i
    if ( ctrl_rstate_get( CURRENT_COLUMN ) == col_i ) h = 1

    # if (highlight[ cord ]) h = 1

    if (h == 1) buffer_append( sprintf("%s",UI_TEXT_BOLD UI_FG_BLUE UI_TEXT_REV ) )

    _tmp_currow = ctrl_rstate_get( CURRENT_ROW )
    if ( logic_row_i == _tmp_currow ) {
        buffer_append( sprintf("%s", UI_FG_GREEN UI_TEXT_REV) )
    }
    if (col_max[ col_i ] > available_cols_len) {
        if (data_wlen[ cord ] > available_cols_len){ buffer_append( sprintf( "%s", str_pad_right( substr(data[ cord ], 1, available_cols_len) "...", available_cols_len + 3, available_cols_len + 3) ) )}
        else {buffer_append( sprintf( "%s", str_pad_right( data[ cord ], available_cols_len + 3, data_wlen[ cord ] ) ) )}
    } else{
        buffer_append( sprintf( "%s", str_pad_right( data[ cord ], col_max[ col_i ], data_wlen[ cord ] ) ) )
    }
    buffer_append( sprintf( "%s", "  " ) )

    # if ((h == 1) && (highrow[ row_i ] != 1)) printf( UI_END )

    if ((h == 1) && ( logic_row_i != _tmp_currow )) buffer_append( sprintf( UI_END ) )
    buffer_append( sprintf( UI_END ) )
}

BEGIN{
    NEWLINE = "\n"

    ctrl_help_item_put("ARROW UP/DOWN/LEFT/ROW", "to move focus")
    ctrl_help_item_put("n/p", "for next/previous page")
    ctrl_help_item_put("c/r/u/d", "for create/retrive/update/delete")
}

function update_logic_view(           logic_row_i, row_i, col_i, start_row, _row_in_page, _tmp_currow){

    if ( ctrl_help_toggle_state() == true ) {
        _row_in_page = max_row_in_page - 3
    } else {
        _row_in_page = max_row_in_page
    }

    buffer_append( ctrl_help_get() "\n\n")

    _tmp_currow = ctrl_rstate_get( CURRENT_ROW )
    start_row = int( (_tmp_currow - 2) / _row_in_page) * _row_in_page + 2

    buffer_append( sprintf("FILTER: %s" NEWLINE, filter[ ctrl_rstate_get( CURRENT_COLUMN ) ]) )

    buffer_append( sprintf("%s     ", UI_TEXT_UNDERLINE UI_TEXT_BOLD) )
    for (col_i=1; col_i<=table_col; col_i++) {
        # limit the length
        if (col_max[ col_i ] > available_cols_len) {
            buffer_append( sprintf( "%s", str_pad_right( data[ 1 KSEP col_i ], available_cols_len + 6, data_wlen[ 1 KSEP col_i ] ) ) )
        } else {
            buffer_append( sprintf( "%s  ", str_pad_right( data[ 1 KSEP col_i ], col_max[ col_i ], data_wlen[ 1 KSEP col_i ] ) ) )
        }
        # buffer_append( sprintf( "%s  ", str_pad_right( data[ 1 KSEP col_i ], col_max[ col_i ], data_wlen[ 1 KSEP col_i ] ) ) )
    }
    buffer_append( sprintf("%s", UI_END) )
    buffer_append( sprintf( NEWLINE ) )

    for (logic_row_i = start_row; logic_row_i <= start_row + _row_in_page; logic_row_i ++) {
        if (logic_row_i > logic_table_row) break
        row_i = logic_table[ logic_row_i ]
        buffer_append( sprintf("%s", str_pad_right(row_i-1, 5)) )
        for (col_i=1; col_i<=table_col; col_i++) {
            update_view_print_cell( logic_row_i, row_i, col_i )
            # buffer_append( sprintf( "%s", "  " ) )
        }
        buffer_append( sprintf("%s" NEWLINE, UI_END) )
    }
    buffer_append( sprintf("SELECT: %s" NEWLINE, data[ _tmp_currow KSEP ctrl_rstate_get( CURRENT_COLUMN ) ]) )
    # buffer_append( NEWLINE )

    send_update( buffer_clear() )
}

# EndSection

# Section: logical table reconstruction
function update_logical_table(  _cord, _elem, row_i, col_i, _ok){
    logic_table[1] = 1
    logic_table_row = 1
    for (row_i = 2; row_i <= table_row; row_i++) {
        _ok = true
        for (col_i = 1; col_i <= table_col; col_i++) {
            _cord = row_i KSEP col_i
            _elem = data[ _cord ]
            _filter = filter[ col_i ]
            if (_filter == "") continue
            if (index(_elem, _filter) < 1) {
                _ok = false
                break
            }
        }
        if ( _ok == true ) {
            logic_table_row = logic_table_row + 1
            logic_table[ logic_table_row ] = row_i
        }
    }

    ctrl_rstate_init( CURRENT_ROW, 2, logic_table_row )
}
# EndSection

# Section: Get data
NR==1 {     update_width_height( $2, $3 );      }

function parse_data(text,
    row_i, col_i,
    elem, elem_wlen){
    # gsub(/\033\[([0-9]+;)*[0-9]+m/, "", text)
    text=str_remove_style(text)
    gsub(/^[ \t\n\b\v\002\001]+/, "", text)
    gsub(/[ \t\b\n\v\002\001]+$/, "", text)

    table_row = split(text, lines, "\002")

    for (row_i = 1; row_i <= table_row; row_i ++) {
        line = lines[row_i]   # Skip the first line
        arr_len = split(line, arr, "\003")
        if (table_col < arr_len) table_col = arr_len

        for (col_i=1; col_i<=arr_len; col_i++) {
            elem = arr[col_i]
            elem = str_trim(elem)

            if (elem ~ /^B%/) {
                elem = substr(elem, 3)
                data_highlight[ row_i KSEP col_i ] = 1
            }

            elem_wlen = wcswidth( elem )
            data[ row_i KSEP col_i ] = elem
            data_wlen [ row_i KSEP col_i ] = elem_wlen

            if (col_max[ col_i ] == "") col_max[ col_i ] = elem_wlen
            if (col_max[ col_i ] < elem_wlen) col_max[ col_i ] = elem_wlen
        }
    }

    ctrl_rstate_init( CURRENT_COLUMN, 1, table_col )
    update_logical_table()
}

NR==2 {         parse_data($0);     }

# EndSection

# Section: ctrl
BEGIN {
    ctrl_sw_init( FILTER_EDIT, false )
    # filter
}

function ctrl_in_filter_state(char_type, char_value){
    if (char_value == "ENTER") {
        ctrl_sw_toggle( FILTER_EDIT)
        update_logical_table()
        return
    }
    ctrl_lineedit_handle( filter, ctrl_rstate_get( CURRENT_COLUMN ), char_type, char_value )
}

function ctrl_not_in_filter_state(char_type, char_value){
    exit_if_detected( char_value )

    if (char_type == "ascii-space")                 return ctrl_sw_toggle( FILTER_EDIT )

    if (char_value == "h")                          return ctrl_help_toggle()

    if (char_value == "n")                          return ctrl_rstate_add( CURRENT_ROW, max_row_in_page )
    if (char_value == "p")                          return ctrl_rstate_add( CURRENT_ROW, - max_row_in_page )

    if (char_value == "UP")                         return ctrl_rstate_dec( CURRENT_ROW )
    if (char_value == "DN")                         return ctrl_rstate_inc( CURRENT_ROW )

    if (char_value == "LEFT" )                      return ctrl_rstate_dec( CURRENT_COLUMN )
    if (char_value == "RIGHT")                      return ctrl_rstate_inc( CURRENT_COLUMN )
}

function ctrl(char_type, char_value) {
    if (ctrl_sw_get( FILTER_EDIT ) == true) {
        ctrl_in_filter_state(char_type, char_value)
    } else {
        ctrl_not_in_filter_state(char_type, char_value)
    }
}

# EndSection

# Section: MSG Flow And End
NR>2 {
    if (try_update_width_height( $0 ) == true) {
        update_logic_view()
    } else {
        cmd=$0
        gsub(/^C:/, "", cmd)
        idx = index(cmd, ":")
        ctrl(substr(cmd, 1, idx-1), substr(cmd, idx+1))
    }
}

END {
    if ( exit_is_with_cmd() == true ) {
        _tmp_currow = ctrl_rstate_get( CURRENT_ROW )

        send_env( "___X_CMD_UI_TABLE_FINAL_COMMAND",    exit_get_cmd() )
        send_env( "___X_CMD_UI_TABLE_CURRENT_ROW",      _tmp_currow )
        send_env( "___X_CMD_UI_TABLE_CURRENT_COLUMN",   ctrl_rstate_get( CURRENT_COLUMN ) )
        send_env( "___X_CMD_UI_TABLE_CUR_LINE",         lines[ _tmp_currow ] )
    }
}
# EndSection
