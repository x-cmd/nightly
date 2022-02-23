

# Section: View

BEGIN {
    ctrl_help_item_put("ARROW UP/DOWN/LEFT/ROW", "to move focus")
    ctrl_help_item_put("ENTER", "for enter")
}

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
}

function view_help(){
    return sprintf("%s\n", th_help_text( ctrl_help_get() ) )
}

function view_body( i, _key_fa ){
    for (i=1; i<=VIEW_TABLE_ROW_SIZE; ++i) {
        for (j=WIN_BEGIN; j<=WIN_END; ++j) {
            _key_fa = SELECTED_KEYPATH_STACK[ j-1 ]
            k = ctrl_win_begin( SELECTED_IDX, _key_fa )
            k = k + j - WIN_BEGIN

            s = ctrl_win_val( SELECTED_IDX, _key_fa )
            v = str_pad_right( DATA[ _key_fa L k ], data_maxcollen(k) + 3
            if (s == k) {
                # selected
                printf("\033[1m;%s\033[0m;", v)
            } else {
                printf("%s", v)
            }
        }
        printf("\n")
    }
}

function view(){
    if (DATA_HAS_CHANGED == false)    return
    DATA_HAS_CHANGED = false

    view_calcuate_geoinfo()

    _component_help         = view_help()
    _component_body         = view_body()
    # _component_statusline   = view_statusline()

    send_update(  _component_help "\n" _component_body )
}

# EndSection

# Section: ctrl
function calculate_offset_from_end( end       i, s, t ){
    if (end == "")  end = MAX_DATA_COL_NUM
    s = 0
    for (i=end; i>=1; --i) {
        s += data_maxcollen(i) + 3 # 3 is column width
        if (s > max_col_size) return i+1
    }
    return 1
}

BEGIN {
    FOCUS_COL = 1
}

function ctrl_cal_colwinsize_by_focus( col,            _selected_keypath ){
    _selected_keypath = SELECTED_KEYPATH_STACK[ col ]

    if (DATA[ _selected_keypath L ] > 0) {
        WIN_END = col + 1
    } else {
        WIN_END = col
    }
    # WIN_BEGIN might be WIN_END + 1
    WIN_BEGIN = calculate_offset_from_end( WIN_END )
}

function ctrl(char_type, char_value,      i, _selected_keypath_fa ){
    if (char_value == "UP")  {
        _selected_keypath_fa = SELECTED_KEYPATH_STACK[ FOCUS_COL - 1 ]
        i = ctrl_win_dec( SELECTED_IDX, _selected_keypath_fa )
        SELECTED_KEYPATH_STACK[ FOCUS_COL ] = _selected_keypath_fa S DATA[ _selected_keypath_fa L i ]
        return ctrl_cal_colwinsize_by_focus( FOCUS_COL )
    }
    if (char_value == "DN") {
        _selected_keypath_fa = SELECTED_KEYPATH_STACK[ FOCUS_COL - 1 ]
        i = ctrl_win_inc( SELECTED_IDX, _selected_keypath_fa )
        SELECTED_KEYPATH_STACK[ FOCUS_COL ] = _selected_keypath_fa S DATA[ _selected_keypath_fa L i ]
        return ctrl_cal_colwinsize_by_focus( FOCUS_COL )
    }

    if (char_value == "LEFT" )  {
        if (FOCUS_COL == 1)     return
        -- FOCUS_COL
        return ctrl_cal_colwinsize_by_focus( FOCUS_COL )
    }

    if (char_value == "RIGHT") {
        if (FOCUS_COL == MAX_DATA_COL_NUM) return

        _selected_keypath_fa = SELECTED_KEYPATH_STACK[ FOCUS_COL ]
        i = ctrl_win_val( SELECTED_IDX, _selected_keypath_fa )

        ++ FOCUS_COL
        SELECTED_KEYPATH_STACK[ FOCUS_COL ] = _selected_keypath_fa S DATA[ _selected_keypath_fa L i ]

        return ctrl_cal_colwinsize_by_focus( FOCUS_COL )
    }
}

# EndSection

# Section: data
BEGIN{
    DATA_MODE_DATA = 1
    DATA_MODE_CTRL = 2
    DATA_MODE = DATA_MODE_DATA

    MAX_DATA_COL_NUM = 0
    MAX_DATA_ROW_NUM = 0
}

NR==1 {  update_width_height( $2, $3 );  }

# TODO: more encapsulation on data model
function data_maxcollen( idx ){
    return DATA[ idx ]
}

function data_maxcollen_set( idx, value ){
    DATA[ idx ] = value
}

BEGIN{
    VIEW_TABLE_ROW_SIZE = 0
}

function reinit_selected_index( size ) {
    # TODO: 10 reserve space
    VIEW_TABLE_ROW_SIZE = max_row_size - 10
    if ( VIEW_TABLE_ROW_SIZE > MAX_DATA_ROW_NUM )     VIEW_TABLE_ROW_SIZE = MAX_DATA_ROW_NUM
    reinit_selected_index_( VIEW_TABLE_ROW_SIZE )
}

function reinit_selected_index_( size, keypath,      l, i ){
    l = DATA[ keypath S L ]
    ctrl_win_init( SELECTED_IDX, keypath, 1, l, size)
    for (i=1; i<=l; ++i) {
        reinit_selected_index_( keypath S DATA[ keypath L i ], size )
    }
}

function handle_item(           i, j, l, _len){
    _key = ""
    if (NR > MAX_DATA_COL_NUM)  MAX_DATA_COL_NUM = NR
    for (i=1; i<=NF; ++i) {
        l = DATA[ _key L ] + 1
        DATA[ _key L ] = l

        if (l > MAX_DATA_ROW_NUM)   MAX_DATA_ROW_NUM = l

        DATA[ _key L l ] = $i
        _len = length( $i )
        if (_len > data_maxcollen( i ) ) {
            data_maxcollen_set( i, _len )
        }
        _key = _key S $i
    }
}

function consume_ctrl(  _cmd){
    if (try_update_width_height( $0 ) == true) {
        if ( is_height_change() == true )  reinit_selected_index()
        return
    }

    DATA_HAS_CHANGED = true

    _cmd=$0
    gsub(/^C:/, "", _cmd)
    idx = index(_cmd, ":")
    ctrl(substr(_cmd, 1, idx-1), substr(_cmd, idx+1))
    view()
}

NR>1 {
    if (DATA_MODE == DATA_MODE_DATA) {
        if ($0 != "---")    return handle_item()
        DATA_MODE = DATA_MODE_CTRL

        reinit_selected_index( )
    } else {
        consume_ctrl()
    }
}

# EndSection
