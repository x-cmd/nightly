



# Section: other
BEGIN {
    ctrl_help_item_put("ARROW UP/DOWN/LEFT/ROW", "to move focus")
    ctrl_help_item_put("n/p", "for next/previous page")
    ctrl_help_item_put("c/r/u/d", "for create/retrive/update/delete")
}
# EndSection

# Section: view
function calcuate_basic_view_info( max_data_row_num ){
    view_item_len = logicview_wlen_avg + 3

    view_col_num = max_col_size / view_item_len
    view_page_item_num = view_col_num * max_data_row_num

    view_page_num = ( logicviewl - 1 ) / view_page_item_num
}

function view(          _selected_item_idx, _iter_item_idx ){
    if ( ctrl_help_toggle_state() == true ) {
        _row_in_page = max_row_in_page - 3
    } else {
        _row_in_page = max_row_in_page
    }

    buffer_append( ctrl_help_get() "\n\n" )

    _selected_item_idx = ctrl_rstate_get( _selected_item_idx  )
    page_index = int( (_selected_item_idx - 1) / view_page_item_num ) + 1
    page_begin = (page_index - 1) * view_page_item_num

    for (i=1; i<=view_row_num; i += ) {
        _iter_item_idx = page_begin + i
        for (j=1; j<=view_col_num; ++j) {
            _item_text = str_pad_right( data[ _iter_item_idx], view_item_len, data_wlen[ _iter_item_idx ]
            if ( _iter_item_idx != _selected_item_idx ) {
                buffer_append( _item_text )
            } else {
                # TODO: highlight
                buffer_append( "\033[1m" _item_text "\033[0m" )
            }
            _iter_item_idx += max_data_row_num
        }
        buffer_append("\n")
    }

    send_update( buffer_clear() )
}
# EndSection

# Section: handle logicview
BEGIN{
    logicviewl = 0
}

function logicview_generate(    _filter,    i ){
    _filter = ctrl_lineedit_get( FILTER_EDIT )

    if ( _filter == "" ) {
        for (i=1; i<=datal; ++i) logicview[i] = i
        logicviewl = datal
        return
    }

    logicviewl = 0
    logicview_wlen_sum = 0
    for (i=1; i<=datal; ++i) {
        if ( index( data[ i ], _filter ) > 0 ) {
            logicview[ ++ logicviewl ] = i
            logicview_wlen_sum += data_wlen[ i ]
        }
    }
    logicview_wlen_avg = logicview_wlen_sum / logicviewl
}

# EndSection

# Section: handle data
BEGIN{
    data_infol = 0
}

function handle_info(){
    if ( $0 == "---" ) {
        DATA_MODE = DATA_MODE_CTRL
        return
    }

    data_info[ ++ data_infol ] = $0
}

function handle_item(       l ){
    if ( $0 == "---" ) {
        ctrl_rstate_init( _selected_item_idx, 1, datal )
        logicviewl = datal
        data_wlen_avg = data_wlen_sum / datal

        DATA_MODE = DATA_MODE_INFO
        return
    }

    data[ ++ datal ] = $0
    l = length( $0 )

    data_wlen[ datal ] = l
    data_wlen_sum += l

    logicview[ datal ] = datal
}

# EndSection

# Section: handle ctrl
function handle_ctrl_in_filter_state(char_type, char_value){
    if (char_value == "ENTER")  {
        logicview_generate()
        return ctrl_sw_toggle( FILTER_EDIT )
    }
    ctrl_lineedit_handle( filter, "", char_type, char_value )
}

function handle_ctrl_in_normal_state(char_type, char_value){
    exit_if_detected( char_value )

    if (char_type == "ascii-space")                 return ctrl_sw_toggle( FILTER_EDIT, true )

    if (char_value == "h")                          return ctrl_help_toggle()

    if (char_value == "n")                          return ctrl_rstate_add( _selected_item_idx, + max_item_size_in_page )
    if (char_value == "p")                          return ctrl_rstate_add( _selected_item_idx, - max_item_size_in_page )

    if (char_value == "UP")                         return ctrl_rstate_dec( _selected_item_idx )
    if (char_value == "DN")                         return ctrl_rstate_inc( _selected_item_idx )

    if (char_value == "LEFT" )                      return ctrl_rstate_add( _selected_item_idx, - max_item_size_in_column )
    if (char_value == "RIGHT")                      return ctrl_rstate_add( _selected_item_idx, + max_item_size_in_column )

    ctrl_rstate_handle_char( _selected_item_idx, char_type, char_value )
}

function handle_ctrl() {
    if (try_update_width_height( $0 ) == true) {
        return
    }

    cmd=$0
    gsub(/^C:/, "", cmd)
    idx = index(cmd, ":")
    char_type = substr(cmd, 1, idx-1)
    char_value = substr(cmd, idx+1))

    if (ctrl_sw_get( FILTER_EDIT ) == true) {
        handle_ctrl_in_filter_state(char_type, char_value)
    } else {
        handle_ctrl_in_normal_state(char_type, char_value)
    }

}
# EndSection

# Section: input and end
NR==1 {     update_width_height( $2, $3 );      }
BEGIN {
    DATA_MODE_ITEM = 1
    DATA_MODE_INFO = 2
    DATA_MODE_CTRL = 3
    DATA_MODE = DATA_MODE_ITEM
}

NR>1 {
    if (DATA_MODE == DATA_MODE_CTRL)        return handle_ctrl()
    if (DATA_MODE == DATA_MODE_ITEM)        return handle_item()
    return handle_info()
}

END {
    if ( exit_is_with_cmd() == true ) {
        _tmp_cur_iter_item_idx = ctrl_rstate_get( _selected_item_idx )

        send_env( "___X_CMD_UI_SELECT_FINAL_COMMAND",           exit_get_cmd() )
        send_env( "___X_CMD_UI_SELECT_CURRENT_ITEM_INDEX",      _tmp_cur_iter_item_idx )
        send_env( "___X_CMD_UI_SELECT_CURENT_ITEM",             data[ _tmp_cur_iter_item_idx ] )
    }
}
# EndSection
