
# Section: help
BEGIN {
    ctrl_help_item_put("ARROW UP/DOWN/LEFT/ROW", "to move focus")
    ctrl_help_item_put("n/p", "for next/previous page")
    ctrl_help_item_put("ENTER", "for enter")
    ctrl_help_item_put("%", "for filter")
    ctrl_help_item_put("/", "for find")
    ctrl_help_item_put("SPACE", "for multiple select")
}
# EndSection

# Section: view

function view_calcuate_geoinfo( ){
    # command line >
    # help: 2/4
    # empty line
    # Filter: 1
    # body:         view_body_row_num
    # INFO: 1
    # status-line

    # 7, 9

    if ( ctrl_help_toggle_state() == true ) {
        view_body_row_num = max_row_size - 10 -1
    } else {
        view_body_row_num = max_row_size - 9 - 1
    }
    view_item_len = model_item_max + 3      # left 3 space

    view_body_col_num = int((max_col_size -1) / view_item_len)
    view_page_item_num = view_body_col_num * view_body_row_num

    view_page_num = int( ( model_len - 1 ) / view_page_item_num ) + 1
}

function view_update(          _selected_item_idx, _iter_item_idx, _data_item_idx, _select_text ){
    if (DATA_HAS_CHANGED == false)    return
    DATA_HAS_CHANGED = false

    view_calcuate_geoinfo()

    buffer_append( ctrl_help_get() "\n\n" )
    buffer_append( sprintf("Filter> %s\n", filter[""] ))
    buffer_append( sprintf("%s\n", UI_FG_BLUE data_header UI_END))

    _selected_item_idx = ctrl_rstate_get( SELECTED_ITEM_IDX )
    page_index = int( (_selected_item_idx - 1) / view_page_item_num ) + 1
    page_begin = int( (page_index - 1) * view_page_item_num)
    for (i=1; i<=view_body_row_num; i ++ ) {
        if (i > model_len) break
        for (j=0; j<view_body_col_num; j++ ) {
            _iter_item_idx = page_begin + i + ( j * view_body_row_num )

            if (_iter_item_idx > model_len) break

            _data_item_idx = model[ _iter_item_idx ]
            _item_text = str_pad_right( data[ _data_item_idx ], view_item_len, data_wlen[ _data_item_idx ] )
            if ( _iter_item_idx != _selected_item_idx ) {
                buffer_append( _item_text )
            } else {
                buffer_append( UI_FG_GREEN UI_TEXT_REV _item_text UI_END )
            }
            _iter_item_idx += max_data_row_num
        }
        buffer_append("\n")
    }
    # ctrl_rstate_set( SELECTED_ITEM_IDX, model[ _selected_item_idx ] )
    buffer_append( "INFO: " UI_FG_GREEN data_info[model[ _selected_item_idx ]] UI_END "\n")
    if ( multiselect_len>0 ) {
        for (i=1; i<=multiselect_len; i ++) {
            _select_text = _select_text UI_FG_GREEN UI_TEXT_REV data[ multiselect[i] ] UI_END " "
        }
        buffer_append( sprintf("SELECT: %s\n",  _select_text ) UI_END "\n")
    }
    send_update( buffer_clear() )
}
# EndSection

# Section: model
function model_generate(    _filter,    i, l){
    _filter = filter[""]
    # model_len = 0
    # model_item_max = 0
    model_len = 0
    for (i=1; i<=data_len; ++i) {
        if (( index( data[ i ], _filter ) > 0 ) || ( _filter == "" )){
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
BEGIN {
    ctrl_sw_init( FILTER_EDIT, false )
    ctrl_sw_init( MULTIPLE_EDIT, false )
    ctrl_sw_init( FIND_EDIT, false )
}

function handle_ctrl_in_filter_state(char_type, char_value){
    if (char_value == "ENTER")  {
        ctrl_sw_toggle( FILTER_EDIT )
        model_generate()
        return
    }
    ctrl_lineedit_handle( filter, "", char_type, char_value )
}

function handle_ctrl_to_move_focus(char_type, char_value){
    if (char_value == "n")                          return ctrl_rstate_add( SELECTED_ITEM_IDX, + view_page_item_num )
    if (char_value == "p")                          return ctrl_rstate_add( SELECTED_ITEM_IDX, - view_page_item_num )

    if (char_value == "UP")                         return ctrl_rstate_dec( SELECTED_ITEM_IDX )
    if (char_value == "DN")                         return ctrl_rstate_inc( SELECTED_ITEM_IDX )

    if (char_value == "LEFT" )                      return ctrl_rstate_add( SELECTED_ITEM_IDX, - view_body_row_num )
    if (char_value == "RIGHT")                      return ctrl_rstate_add( SELECTED_ITEM_IDX, + view_body_row_num )
}

function handle_ctrl_to_select_item(char_value) {
    if (char_value != "ENTER")  return
    if (ctrl_sw_get( MULTIPLE_EDIT ) == false) {
        return exit_with_elegant( char_value )
    } else {
        for (i=1; i<=multiselect_len; ++i) {
            if ( multiselect[ i ] == ctrl_rstate_get( SELECTED_ITEM_IDX )) {
                # delete multiselect[ i ]
                -- multiselect_len
                for (j=i; j<=multiselect_len; j++) {
                    multiselect[ j ] = multiselect[ j + 1 ]
                }
                return
            }
        }
        multiselect[ ++ multiselect_len ] = model[ ctrl_rstate_get( SELECTED_ITEM_IDX ) ]
        return
    }
}

function handle_ctrl_in_normal_state(char_type, char_value) {
    EXIT_CHAR_LIST = ",q,"
    exit_if_detected( char_value )

    if (char_type == "ascii-space") {
        (ctrl_sw_get( MULTIPLE_EDIT ) == false) ? ctrl_sw_toggle( MULTIPLE_EDIT ) : exit_with_elegant( char_value )
        return
    }
    if (char_value == "/")                          return ctrl_sw_toggle( FIND_EDIT )    # find
    if (char_value == "%")                          return ctrl_sw_toggle( FILTER_EDIT )    # filter

    if (char_value == "h")                          return ctrl_help_toggle()

    handle_ctrl_to_move_focus(char_type, char_value)    # ARROW UP/DOWN/LEFT/ROW/n/p
    handle_ctrl_to_select_item(char_value)      # select item
    ctrl_rstate_handle_char( SELECTED_ITEM_IDX, char_type, char_value )
}

function ctrl(char_type, char_value) {
    if (ctrl_sw_get( FILTER_EDIT ) == true) {
        handle_ctrl_in_filter_state(char_type, char_value)
    } else {
        handle_ctrl_in_normal_state(char_type, char_value)
    }
}

function consume_ctrl() {
    if (try_update_width_height( $0 ) == true) {
        return
    }

    DATA_HAS_CHANGED = true

    cmd=$0
    gsub(/^C:/, "", cmd)
    idx = index(cmd, ":")
    ctrl(substr(cmd, 1, idx-1), substr(cmd, idx+1))
    view_update()
}
# EndSection

# Section: consume data
function consume_info(){
    if ( $0 == "---" ) {
        DATA_MODE = DATA_MODE_CTRL
        return
    }

    data_info[ ++ data_info_len ] = $0
}

function consume_item(       l ){
    if ( $0 == "---" ) {
        DATA_MODE = DATA_MODE_INFO
        model_generate()
        data_info_len = 0
        return
    }
    data[ ++ data_len ] = $0
    data_wlen[ data_len ] = wcswidth( $0 )

    # Show the first screen to improve use experience
    if ( data_len == ((max_row_size - 9) * 2)) {
        model_generate()
        view_update()
    }
}
# EndSection

# Section: input and end
BEGIN {
    DATA_MODE_ITEM = 1
    DATA_MODE_INFO = 2
    DATA_MODE_CTRL = 3
    DATA_MODE = DATA_MODE_ITEM
}
NR==1 {     update_width_height( $2, $3 );      }
NR==2 {  data_header = str_trim($0) }
NR>2 {
    if (DATA_MODE == DATA_MODE_CTRL) { consume_ctrl() }
    else if (DATA_MODE == DATA_MODE_ITEM) { consume_item() }
    else { consume_info() }
}

END {
    if ( exit_is_with_cmd() == true ) {
        if ( multiselect_len > 0 ) {
            send_env( "___X_CMD_UI_SELECT_FINAL_COMMAND",           exit_get_cmd() )
            for (i=1; i<=multiselect_len; ++ i) {
                _tmp_cur_iter_item_idx = multiselect[ i ]
                send_env( "___X_CMD_UI_SELECT_ITEM_INDEX" i,      _tmp_cur_iter_item_idx )
                send_env( "___X_CMD_UI_SELECT_ITEM" i,             data[ _tmp_cur_iter_item_idx ] )
            }
            send_env( "___X_CMD_UI_SELECT_MULTIPLE_LEN",           multiselect_len )
        }
        _tmp_cur_iter_item_idx = ctrl_rstate_get( SELECTED_ITEM_IDX )
        _tmp_cur_iter_item_idx = model[ _tmp_cur_iter_item_idx ]

        send_env( "___X_CMD_UI_SELECT_FINAL_COMMAND",           exit_get_cmd() )
        send_env( "___X_CMD_UI_SELECT_CURRENT_ITEM_INDEX",      _tmp_cur_iter_item_idx )
        send_env( "___X_CMD_UI_SELECT_CURENT_ITEM",             data[ _tmp_cur_iter_item_idx ] )
    }

}
# EndSection
