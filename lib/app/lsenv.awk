
# Section: view
BEGIN {
    ctrl_help_item_put("ARROW UP/DOWN/LEFT/ROW", "to move focus")
    ctrl_help_item_put("ENTER", "for enter")
}

function view_calcuate_geoinfo(){
    if ( VIEW_BODY_ROW_SIZE >= MAX_DATA_ROW_NUM ) return
    if ( ctrl_help_toggle_state() == true )         VIEW_BODY_ROW_SIZE = max_row_size - 9 - 1
    else                                            VIEW_BODY_ROW_SIZE = max_row_size - 8 - 1
}

function view(      _component_help, _component_body){
    view_calcuate_geoinfo()

    _component_help         = view_help()
    _component_body         = view_body()

    send_update( _component_help "\n" _component_body  )
}

function view_help(){
    return sprintf("%s", th_help_text( ctrl_help_get() ) )
}

function view_body_info_for_dir(view_grid, _selected_keypath,         i, l, _selected_index_of_this_column, _content){
    l = data[ _selected_keypath L]
    _selected_index_of_this_column = ctrl_win_val( treectrl, _selected_keypath )
    for (i=1; i<=l; ++i) {
        _tmp = data[ _selected_keypath L i ]
        _content = str_pad_right( _tmp, _max_col_len)
        if ( _selected_index_of_this_column == i ) _content = th(TH_CATSEL_ITEM_UNFOCUSED_SELECT, _content)
        view_grid[ i S 0 ] = _content
    }
    return data[ _selected_keypath A "MAX_LEN" ]
}

function view_body_info_for_file(view_grid, _selected_keypath, _selected,            _file_type, _file_size, _last_access, _last_modify, _last_change, _permission, _uid, _gid, i, l, _max_len){

    _file_type       = data[ _selected_keypath A "TYPE" ]
    _file_size       = data[ _selected_keypath A "SIZE" ]
    _last_access     = data[ _selected_keypath A "ACCESS" ]
    _last_modify     = data[ _selected_keypath A "MODIFY" ]
    _last_change     = data[ _selected_keypath A "CHANGE" ]
    _permission      = data[ _selected_keypath A "PERM" ]
    _uid             = data[ _selected_keypath A "UID" ]
    _gid             = data[ _selected_keypath A "GID" ]

    view_grid[ 1 S 0 ] = sprintf("  Name: %s  Size: %s  Type: %s", _selected, _file_size, _file_type)
    view_grid[ 2 S 0 ] = sprintf("Access: %s  Uid: ( %s )  Gid: ( %s )", _permission, _uid, _gid)
    view_grid[ 3 S 0 ] = sprintf("Access: %s", _last_access)
    view_grid[ 4 S 0 ] = sprintf("Modify: %s", _last_modify)
    view_grid[ 5 S 0 ] = sprintf("Change: %s", _last_change)

    for (i=1; i<=5; ++i) {
        l = length( view_grid[ i S 0 ])
        if (_max_len < l)   _max_len = l
    }
    view_grid[ 0 S 0 ] = ui_str_rep("_", _max_len)
    return _max_len
}


function view_body_cal_beginning_col( info_view_maxlen,     _col_end, _col_size, i, _kp, _len ){
    _col_size = max_col_size - info_view_maxlen - 2
    _col_end = stack_length( treectrl )
    for ( i=_col_end; i>=1; --i ) {
        _kp = treectrl[ i ]
        _len = data[ _kp A "MAX_LEN" ] + 2
        if (_col_size < _len)   return i+1
        _col_size -= _len
    }
    return 1
}

function view_body_info( view_grid,             _selected, _selected_keypath ){
    _selected = data[ cur_keypath L ctrl_win_val( treectrl, cur_keypath ) ]
    _selected_keypath = cur_keypath S _selected
    if ( is_expandable( _selected_keypath ) == true )    return     view_body_info_for_dir(  view_grid, _selected_keypath )
    return                                                          view_body_info_for_file( view_grid, _selected_keypath , _selected)
}

function view_body_show(view_grid, info_view_maxlen,                _return, i, _selected, _selected_keypath, _view_info_grid ){

    for (i=0; i<=VIEW_BODY_ROW_SIZE; ++i) {
        _selected = data[ cur_keypath L ctrl_win_val( treectrl, cur_keypath ) ]
        _selected_keypath = cur_keypath S _selected
        if ( is_expandable( _selected_keypath ) == false )      _view_info_grid = th(TH_CATSEL_INFO, str_pad_right(view_grid[ i S 0 ], info_view_maxlen))
        else                                                    _view_info_grid = view_grid[ i S 0 ]
        _return = _return UI_END "\n" "  " view_grid[ i ] "  " _view_info_grid
    }
    return _return
}

function view_body( view_grid,                  _info_view_maxlen, _col_start, _col_size, j, i, _kp, _offset_for_this_column, _selected_index_of_this_column, _max_col_len, _i_for_this_column, _tmp, _content ){
    _info_view_maxlen = view_body_info( view_grid )
    _col_start = view_body_cal_beginning_col( _info_view_maxlen )
    _col_size  = stack_length( treectrl )

    for (j=_col_start; j<=_col_size; ++j) {
        _kp = treectrl[ j ]
        _offset_for_this_column = ctrl_win_begin( treectrl, _kp )
        _selected_index_of_this_column = ctrl_win_val( treectrl, _kp )
        _max_col_len = data[ _kp A "MAX_LEN" ] + 2

        view_grid[ 0 ] = view_grid[ 0 ] ui_str_rep("_", _max_col_len)
        for (i=1; i<=VIEW_BODY_ROW_SIZE; ++i) {
            _i_for_this_column = _offset_for_this_column + i - 1
            if (_i_for_this_column > data[ _kp L]) {
                view_grid[ i ] = view_grid[ i ] ui_str_rep(" ", _max_col_len)
                continue
            }

            _tmp = data[ _kp L _i_for_this_column ]
            _content = str_pad_right( _tmp, _max_col_len)
            if (_kp == cur_keypath) {
                STYLE_CATSEL_SELECTED      =   TH_CATSEL_ITEM_FOCUSED_SELECT
                STYLE_CATSEL_UNSELECTED    =   TH_CATSEL_ITEM_FOCUSED_UNSELECT
            } else {
                STYLE_CATSEL_SELECTED      =   TH_CATSEL_ITEM_UNFOCUSED_SELECT
                STYLE_CATSEL_UNSELECTED    =   TH_CATSEL_ITEM_UNFOCUSED_UNSELECT
            }
            if ( is_expandable( _kp S _tmp ) == false )                     _content = th(TH_CATSEL_UNDIRECTORY,    _content)
            if ( _selected_index_of_this_column == _i_for_this_column )     _content = th(STYLE_CATSEL_SELECTED,    _content)
            else                                                            _content = th(STYLE_CATSEL_UNSELECTED,  _content)
            view_grid[ i ] = view_grid[ i ] _content
        }
    }

    return view_body_show( view_grid, _info_view_maxlen )
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
        if (( is_expandable( _selected_keypath ) == false) || ( data[ _selected_keypath L ] < 1)) return
        cur_keypath = _selected_keypath
        stack_push( treectrl, cur_keypath )
        return
    }
}

# EndSection

# Section: cmd source
NR==1{
    try_update_width_height( $0 )

    cur_keypath = "."
    getdata( cur_keypath )
    stack_push( treectrl, cur_keypath )
    prepare_selected_item_data()
    view()
}

NR>1{
    if ( try_update_width_height( $0 ) )    next
    # TODO: if it is update, recalculate the view.

    _cmd=$0
    gsub(/^C:/, "", _cmd)
    idx = index(_cmd, ":")
    ctrl(substr(_cmd, 1, idx-1), substr(_cmd, idx+1))
    prepare_selected_item_data()
    view()
}
# EndSection

# Section: Functions differ in apps

function is_expandable( curkp ){
    return ( data[ curkp A "TYPE" ] == "directory" ) ? true : false
}

function prepare_selected_item_data(        _selected, _selected_keypath ){
    _selected = data[ cur_keypath L ctrl_win_val(treectrl, cur_keypath) ]
    _selected_keypath = cur_keypath S _selected
    if ( is_expandable( _selected_keypath ) == false ) return
    getdata( _selected_keypath )
}

BEGIN {
    daemon_cmd = ". ~/.x-cmd/xrc/latest; xrc ui/lib/lsenv; ___x_cmd_ui_lsenv_fetch_info"
}

function get_daemon_data( actual_cmd ){
    print actual_cmd | daemon_cmd
    while (1) {
        daemon_cmd | getline _line
        if ( _line == "---" )  break

        # Parse the data from xenv
    }
}

# function getdata(curkp,         _file_keypath, cmd_format, _cmd, _line, _code, _arrl, _arr, i, _name, _len, _max_len ){
#     # cache
#     if (data[ curkp L ] != "")  return
#     _file_keypath = curkp
#     gsub(S, "/", _file_keypath)
#     cmd_format = "ls -A | xargs stat -c \"%%n\t%%F\t%%s\t%%x\t%%y\t%%z\t%%A\t%%u/%%U\t%%g/%%G\" 2>/dev/null; "
#     if (_file_keypath != ".")  cmd_format = "cd %s; " cmd_format " cd - >/dev/null"

#     _cmd = sprintf(cmd_format, _file_keypath)
#     for (i=1; _cmd | getline _line; i++) {
#         _arrl = split( _line, _arr, "\t" )
#         _name = _arr[1]
#         data[ curkp L i ] = _name
#         data[ curkp S _name A "TYPE" ]      = _arr[2]
#         data[ curkp S _name A "SIZE" ]      = _arr[3]
#         data[ curkp S _name A "ACCESS" ]    = _arr[4]
#         data[ curkp S _name A "MODIFY" ]    = _arr[5]
#         data[ curkp S _name A "CHANGE" ]    = _arr[6]
#         data[ curkp S _name A "PERM" ]      = _arr[7]
#         data[ curkp S _name A "UID" ]       = _arr[8]
#         data[ curkp S _name A "GID" ]       = _arr[9]
#         _len = wcswidth(_name)
#         if ( _max_len < _len) _max_len = _len
#     }
#     data[ curkp A "MAX_LEN" ]    = _max_len
#     i-=1
#     data[ curkp L ] = i
#     if ( MAX_DATA_ROW_NUM < i ) MAX_DATA_ROW_NUM = i
#     ctrl_win_init( treectrl, curkp, 1, data[ curkp L ], get_view_body_row_size() )
#     return
# }

END {
    if ( exit_is_with_cmd() == true ) {
        _selected = data[ cur_keypath L ctrl_win_val( treectrl, cur_keypath ) ]
        _selected_keypath = cur_keypath S _selected
        send_env( "___X_CMD_UI_CATSEL_FINAL_COMMAND",    exit_get_cmd() )
        send_env( "___X_CMD_UI_CATSEL_CURRENT_ITEM",  _selected_keypath )
    }
}
# EndSection
