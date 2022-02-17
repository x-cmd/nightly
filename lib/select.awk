
# Section: help
BEGIN {
    ctrl_help_item_put("ARROW UP/DOWN/LEFT/ROW", "to move focus")
    ctrl_help_item_put("n/p", "for next/previous page")
    ctrl_help_item_put("c/r/u/d", "for create/retrive/update/delete")
}
# EndSection

# Section: view
function view_calcuate_geoinfo( ){
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

    view_item_len = model_item_max + 3      # left 3 space

    view_body_col_num = max_col_size / view_item_len
    view_page_item_num = view_body_col_num * view_body_row_num

    view_page_num = int( model_len - 1 ) / view_page_item_num + 1
}

function view_update(          _selected_item_idx, _iter_item_idx, _data_item_idx ){
    if (DATA_HAS_CHANGED == false)    return
    DATA_HAS_CHANGED = false

    view_calcuate_geoinfo()

    buffer_append( ctrl_help_get() "\n\n" )
    buffer_append( "Filter> "ctrl_rstate_get( FILTER_EDIT ) )

    _selected_item_idx = ctrl_rstate_get( SELECTED_ITEM_IDX  )
    page_index = int( (_selected_item_idx - 1) / view_page_item_num ) + 1
    page_begin = (page_index - 1) * view_page_item_num

    for (i=1; i<=view_row_num; i += ) {
        _iter_item_idx = page_begin + i
        for (j=1; j<=view_body_col_num; ++j) {
            _data_item_idx = model[ _iter_item_idx ]

            _item_text = str_pad_right( data[ _data_item_idx ], view_item_len, data_wlen[ _iter_item_idx ] )
            if ( _iter_item_idx != _selected_item_idx ) {
                buffer_append( _item_text )
            } else {
                buffer_append( "\033[32m" _item_text "\033[0m" )
            }
            _iter_item_idx += max_data_row_num
        }
        buffer_append("\n")
    }

    send_update( buffer_clear() )
}
# EndSection

# Section: model
function model_generate(    _filter,    i, l ){
    _filter = ctrl_lineedit_get( FILTER_EDIT )

    if ( _filter == "" ) {
        for (i=1; i<=data_len; ++i) {
            model[i] = i
            l = data_wlen[ i ]
            if (model_item_max < l) model_item_max = l
        }
        model_len = data_len
        return
    }

    model_len = 0
    model_item_max = 0
    for (i=1; i<=data_len; ++i) {
        if ( index( data[ i ], _filter ) > 0 ) {
            model[ ++ model_len ] = i
            l = data_wlen[ i ]
            if (model_item_max < l) model_item_max = l
        }
    }

    ctrl_rstate_init( SELECTED_ITEM_IDX, 1, model_len )
    DATA_HAS_CHANGED = true
}
# EndSection

# Section: ctrl
function handle_ctrl_in_filter_state(char_type, char_value){
    if (char_value == "ENTER")  {
        model_generate()
        return ctrl_sw_toggle( FILTER_EDIT )
    }
    ctrl_lineedit_handle( filter, "", char_type, char_value )
}

function handle_ctrl_in_normal_state(char_type, char_value){
    exit_if_detected( char_value )

    if (char_type == "ascii-space")                 return ctrl_sw_toggle( FILTER_EDIT, true )

    if (char_value == "h")                          return ctrl_help_toggle()

    if (char_value == "n")                          return ctrl_rstate_add( SELECTED_ITEM_IDX, + view_page_item_num )
    if (char_value == "p")                          return ctrl_rstate_add( SELECTED_ITEM_IDX, - view_page_item_num )

    if (char_value == "UP")                         return ctrl_rstate_dec( SELECTED_ITEM_IDX )
    if (char_value == "DN")                         return ctrl_rstate_inc( SELECTED_ITEM_IDX )

    if (char_value == "LEFT" )                      return ctrl_rstate_add( SELECTED_ITEM_IDX, - view_body_row_num )
    if (char_value == "RIGHT")                      return ctrl_rstate_add( SELECTED_ITEM_IDX, + view_body_row_num )

    ctrl_rstate_handle_char( SELECTED_ITEM_IDX, char_type, char_value )
}

function consume_ctrl() {
    if (try_update_width_height( $0 ) == true) {
        return
    }

    DATA_HAS_CHANGED = true

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

# Section: consume data
function consume_info(){
    if ( $0 == "---" ) {
        DATA_MODE = DATA_MODE_CTRL
        view_update()
        return
    }

    data_info[ ++ data_info_len ] = $0
}

function consume_item(       l ){
    if ( $0 == "---" ) {
        model_generate()
        DATA_MODE = DATA_MODE_INFO
        data_info_len = 0
        return
    }

    data[ ++ data_len ] = $0
    data_wlen[ data_len ] = wcswidth( $0 )

    # Show the first screen to improve use experience
    if ( data_len == max_row_size ) {
        model_generate()
        view_update()
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
    if (DATA_MODE == DATA_MODE_CTRL)        return consume_ctrl()
    if (DATA_MODE == DATA_MODE_ITEM)        return consume_item()
    return consume_info()
}

END {
    if ( exit_is_with_cmd() == true ) {
        _tmp_cur_iter_item_idx = ctrl_rstate_get( SELECTED_ITEM_IDX )
        _tmp_cur_iter_item_idx = model[ _tmp_cur_iter_item_idx ]

        send_env( "___X_CMD_UI_SELECT_FINAL_COMMAND",           exit_get_cmd() )
        send_env( "___X_CMD_UI_SELECT_CURRENT_ITEM_INDEX",      _tmp_cur_iter_item_idx )
        send_env( "___X_CMD_UI_SELECT_CURENT_ITEM",             data[ _tmp_cur_iter_item_idx ] )
    }
}
# EndSection
