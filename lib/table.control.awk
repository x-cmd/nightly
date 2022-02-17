
# Section: Global data
BEGIN {
    KSEP = "\001"
    if (COL_MAX_SIZE == "")       COL_MAX_SIZE = 30

    ctrl_help_item_put("ARROW UP/DOWN/LEFT/ROW", "to move focus")
    ctrl_help_item_put("n/p", "for next/previous page")
    ctrl_help_item_put("c/r/u/d", "for create/retrive/update/delete")
}
# EndSection

# Section: view
function update_view_print_cell(model_row_i, data_row_i, col_i,       h, _size, _tmp_currow){

    if ( ctrl_rstate_get( CURRENT_COLUMN ) == col_i )           buffer_append( sprintf("%s",UI_TEXT_BOLD UI_FG_BLUE UI_TEXT_REV ) )
    if ( ctrl_rstate_get( CURRENT_ROW ) == model_row_i )        buffer_append( sprintf("%s", UI_FG_GREEN UI_TEXT_REV) )

    cord = data_row_i KSEP col_i
    if (col_max[ col_i ] <= COL_MAX_SIZE) {
        buffer_append( sprintf( "%s", str_pad_right( data[ cord ], col_max[ col_i ], data_wlen[ cord ] ) ) )
    } else {
        if (data_wlen[ cord ] > COL_MAX_SIZE){
            buffer_append( sprintf( "%s", str_pad_right( substr(data[ cord ], 1, COL_MAX_SIZE) "...", COL_MAX_SIZE + 3, COL_MAX_SIZE + 3) ) )
        } else {
            buffer_append( sprintf( "%s", str_pad_right( data[ cord ], COL_MAX_SIZE + 3, data_wlen[ cord ] ) ) )
        }
    }
    buffer_append( sprintf( "%s", "  " ) )
    buffer_append( sprintf( UI_END ) )
}

function view_update_header(       col_i){
    buffer_append( sprintf("%s     ", UI_TEXT_UNDERLINE UI_TEXT_BOLD) )
    for (col_i=1; col_i<=data_col_num; col_i++) {
        # limit the length
        if (col_max[ col_i ] > COL_MAX_SIZE) {
            buffer_append( sprintf( "%s", str_pad_right( data_header_arr[ col_i ], COL_MAX_SIZE + 6, data_wlen[ 1 KSEP col_i ] ) ) )
        } else {
            buffer_append( sprintf( "%s  ", str_pad_right( data_header_arr[ col_i ], col_max[ col_i ], data_wlen[ 1 KSEP col_i ] ) ) )
        }
        # buffer_append( sprintf( "%s  ", str_pad_right( data[ 1 KSEP col_i ], col_max[ col_i ], data_wlen[ 1 KSEP col_i ] ) ) )
    }

    buffer_append( sprintf("%s\n", UI_END) )
}

function view_calcuate_geoinfo(){
    # command line >
    # help: 1/3
    # empty line
    # Filter: 1
    # body:         view_body_row_num
    # status-line

    # 5, 7
    if ( ctrl_help_toggle_state() == true ) {
        view_body_row_num = max_row_size - 7
    } else {
        view_body_row_num = max_row_size - 5
    }
}

function update_logic_view(           model_row_i, row_i, col_i, model_start_row, _row_in_page, _tmp_currow){
    if (DATA_HAS_CHANGED == false)    return
    DATA_HAS_CHANGED = false

    view_calcuate_geoinfo()

    buffer_append( ctrl_help_get() "\n\n" )
    buffer_append( sprintf("FILTER: %s\n", filter[ ctrl_rstate_get( CURRENT_COLUMN ) ]) )

    _tmp_currow = ctrl_rstate_get( CURRENT_ROW )
    model_start_row = int( (_tmp_currow - 1) / view_body_row_num) * view_body_row_num + 1

    view_update_header()

    # view_update_table
    for (model_row_i = model_start_row; model_row_i <= model_start_row + view_body_row_num; model_row_i ++) {
        if (model_row_i > model_row) break
        data_row_i = model[ model_row_i ]
        buffer_append( sprintf("%s", str_pad_right( data_row_i, 5 )) )
        for (col_i=1; col_i<=data_col_num; col_i++) {
            update_view_print_cell( model_row_i, data_row_i, col_i )
            # buffer_append( sprintf( "%s", "  " ) )
        }
        buffer_append( sprintf("%s\n", UI_END) )
    }
    buffer_append( sprintf("SELECT: %s\n", data[ _tmp_currow KSEP ctrl_rstate_get( CURRENT_COLUMN ) ]) )

    send_update( buffer_clear() )
}
# EndSection

# Section: model
function model_generate(  _cord, _elem, row_i, col_i, _ok){
    model_row = 0

    for (col_i = 1; col_i <= data_col_num; col_i ++) {
        if (col_max[ col_i ] < data_header_arr_wlen[ col_i ])   col_max[ col_i ] = data_header_arr_wlen[ col_i ]
    }

    for (row_i = 1; row_i <= table_row; row_i++) {
        _ok = true
        for (col_i = 1; col_i <= data_col_num; col_i++) {
            _filter = filter[ col_i ]
            if (_filter == "") continue
            if (index(data[ row_i KSEP col_i ], _filter) < 1) {
                _ok = false
                break
            }
        }
        if ( _ok == true ) {
            model[ ++ model_row ] = row_i

            for (col_i = 1; col_i <= data_col_num; col_i ++) {
                _cord = row_i KSEP col_i
                if (col_max[ col_i ] < data_wlen[ _cord ])   col_max[ col_i ] = data_wlen[ _cord ]
            }
        }
    }

    ctrl_rstate_init( CURRENT_ROW, 1, model_row )
    DATA_HAS_CHANGED = true
}
# EndSection

# Section: ctrl
BEGIN {     ctrl_sw_init( FILTER_EDIT, false )          }

function ctrl_in_filter_state(char_type, char_value){
    if (char_value == "ENTER") {
        ctrl_sw_toggle( FILTER_EDIT)
        model_generate()
        return
    }
    ctrl_lineedit_handle( filter, ctrl_rstate_get( CURRENT_COLUMN ), char_type, char_value )
}

function ctrl_in_normal_state(char_type, char_value){
    exit_if_detected( char_value )

    if (char_type == "ascii-space")                 return ctrl_sw_toggle( FILTER_EDIT )

    if (char_value == "h")                          return ctrl_help_toggle()

    if (char_value == "n")                          return ctrl_rstate_add( CURRENT_ROW, + view_body_row_num )
    if (char_value == "p")                          return ctrl_rstate_add( CURRENT_ROW, - view_body_row_num )

    if (char_value == "UP")                         return ctrl_rstate_dec( CURRENT_ROW )
    if (char_value == "DN")                         return ctrl_rstate_inc( CURRENT_ROW )

    if (char_value == "LEFT" )                      return ctrl_rstate_dec( CURRENT_COLUMN )
    if (char_value == "RIGHT")                      return ctrl_rstate_inc( CURRENT_COLUMN )
}

function ctrl(char_type, char_value) {
    if (ctrl_sw_get( FILTER_EDIT ) == true) {
        ctrl_in_filter_state(char_type, char_value)
    } else {
        ctrl_in_normal_state(char_type, char_value)
    }
}

# EndSection

# Section: consumer_item and consume_header
function consumer_item() {
    if (text == "---") {
        ctrl_rstate_init( CURRENT_COLUMN, 1, data_col_num )
        model_generate()

        DATA_MODE = DATA_MODE_CTRL
        return
    }

    data_len += 1
    item_arr_len = split($0, item_arr, "\003")
    for (i=1; i<=item_arr_len; i++) {
        elem = item_arr[i]
        elem = str_trim(elem)
        elem_wlen = wcswidth( elem )

        data[ data_len KSEP i ] = elem
        data_wlen [ data_len KSEP i ] = elem_wlen

        if (col_max[ i ] < elem_wlen) col_max[ i ] = elem_wlen
    }

    # Show the first screen to improve use experience
    if ( data_len == max_row_size ) {
        model_generate()
        view_update()
    }
}

function consume_header(){
    data_col_num = split($0, data_header_arr, "\003")

    for (i=1; i<=data_col_num; i++) {
        elem = str_trim(data_header_arr[i])
        elem_wlen = wcswidth( elem )

        data_header_arr_wlen [ i ] = elem_wlen
    }
}
# EndSection

# Section: MSG Flow And End
NR==1 {     update_width_height( $2, $3 );      }
BEGIN {
    DATA_MODE_ITEM = 1
    DATA_MODE_CTRL = 2
    DATA_MODE = DATA_MODE_ITEM
}

NR==2 {  consume_header(); }

NR>2 {
    if ( DATA_MODE == DATA_MODE_CTRL ) {
        if (try_update_width_height( $0 ) == true) {
            update_logic_view()
        } else {
            DATA_HAS_CHANGED = true

            cmd=$0
            gsub(/^C:/, "", cmd)
            idx = index(cmd, ":")
            ctrl(substr(cmd, 1, idx-1), substr(cmd, idx+1))
        }
        return
    }

    consume_item($0);
}

END {
    if ( exit_is_with_cmd() == true ) {
        _tmp_currow = ctrl_rstate_get( CURRENT_ROW )
        _tmp_currow = model[ _tmp_currow ]

        send_env( "___X_CMD_UI_TABLE_FINAL_COMMAND",    exit_get_cmd() )
        send_env( "___X_CMD_UI_TABLE_CURRENT_ROW",      _tmp_currow )
        send_env( "___X_CMD_UI_TABLE_CURRENT_COLUMN",   ctrl_rstate_get( CURRENT_COLUMN ) )
        send_env( "___X_CMD_UI_TABLE_CUR_LINE",         data[ _tmp_currow ] )
    }
}
# EndSection
