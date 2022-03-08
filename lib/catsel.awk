

# Section: ctrl

function get_view_body_row_size( col     ,l) {
    # TODO: 10 reserve space
    VIEW_BODY_ROW_SIZE = max_row_size - 10
    if ( VIEW_BODY_ROW_SIZE > MAX_DATA_ROW_NUM )     VIEW_BODY_ROW_SIZE = MAX_DATA_ROW_NUM
}

# Different
function ctrl_info_panel(){

    if (char_value == "UP") {

    } else if (char_value == "DN") {

    } else if ((char_value == "LEFT") {
        # TODO: maybe using enter to exit
        IN_INFO_PANEL = false
    } else if (char_value == "RIGHT") {
        # Edit
    }
    else                                                                return
}

function ctrl(char_type, char_value,        _selected){
    exit_if_detected( char_value, ",q,ENTER," )

    if (char_value == "h")                                              return ctrl_help_toggle()
    if (IN_INFO_PANEL == true)                                          return ctrl_info_panel()

    if (char_value == "UP")                                             ctrl_win_rdec( treectrl, cur_keypath )
    else if (char_value == "DN")                                        ctrl_win_rinc( treectrl, cur_keypath )
    else if ((char_value == "LEFT") && (stack_length( treectrl ) != 1)) {
        stack_pop( treectrl )
        cur_keypath = stack_top( treectrl )
    } else if (char_value == "RIGHT") {
        _selected = data[ cur_keypath L ctrl_win_val( treectrl, cur_keypath ) ]
        _selected_keypath = cur_keypath S _selected
        if ( data[ _selected_keypath A "EXPANDABLE" ] == false ) {
            IN_INFO_PANEL = true
            # Application specific code ...
            # ctrl_win_init( infoctrl, cur_keypath, 1, data[ cur L ], get_view_body_row_size() )
            # Just Ignore ...
        } else {
            cur_keypath = _selected_keypath
            stack_push( treectrl, cur_keypath )
            prepare_selected_item_data()
        }
    }
    else                                                                return

}

# EndSection

# Section: cmd source
# update
# TODO: Not provided in the catsel yet.
NR==1{
    try_update_width_height( $0 )

    cur_keypath = "."
    getdata( cur_keypath )
    ctrl_win_init( treectrl, cur_keypath, 1, data[ cur L ], get_view_body_row_size() )

    prepare_selected_item_data()
}

NR>1{
    if (try_update_width_height( $0 ) == true)
    _cmd=$0
    gsub(/^C:/, "", _cmd)
    idx = index(_cmd, ":")
    ctrl(substr(_cmd, 1, idx-1), substr(_cmd, idx+1))
    view()
}
# EndSection

# Section: Functions differ in apps
function prepare_selected_item_data( ){
    ctrl_win_init( ctrobj, cur_keypath, 1, data[ cur L ], get_view_body_row_size() )
    if ( data[ cur_keypath A "TYPE" ] == "directory" )  getdata( cur_keypath )
}

function getdata(curkp,    _cmd, _line, _code, _arrl, _arr, i ){
    # cache
    if (data[ curkp ] != "")  return
    if (curkp != ".") {
        cmd_format = "cd %s; ls -A | xargs stat -c \"%%n\t%%F\" 2>/dev/null; cd - >/dev/null"
    } else {
        cmd_format = "ls -A %s | xargs stat -c \"%%n\t%%F\""
    }
    _cmd = sprintf(cmd_format, curkp)
    i=0
    while (1) {
        i+=1
        _code = _cmd | getline _line
        if (_code == 0) break
        _arrl = split( _line, _arr, "\t" )
        name = _arr[1]
        data[ curkp L i ] = name
        data[ curkp S name A "TYPE" ] = _arr[2]
    }
    data[ curkp L ] = i
}

END {
    if ( exit_is_with_cmd() == true ) {
        send_env( "___X_CMD_UI_CATEGORYSELECT_FINAL_COMMAND",    exit_get_cmd() )
        send_env( "___X_CMD_UI_CATEGORYSELECT_CURRENT_ITEM",        cur_keypath )
    }
}
# EndSection


