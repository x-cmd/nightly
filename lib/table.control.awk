
# Section: Global data
BEGIN {

    KSEP = "\001"

    if (available_row == "") {
        available_row = 10
    }

    if (available_cols_len == "") {
        available_cols_len = 30
    }

    max_row_in_page = available_row

    start_row = 1
    
    cur_col = 1
    cur_row = 0

    table_col = 0

    max_col_size = -1
    max_row_size = -1

    # data
    # data_wlen
    # data_highlight
    # col_max
}
# EndSection

# Section

BEGIN {
    BUFFER = ""
}

function bufferln(data){
    if (BUFFER == "") BUFFER = data
    else BUFFER = BUFFER "\n" data
}

function buffer_append(data){
    BUFFER = BUFFER data
}

function buffer_clear(          buf){
    buf = BUFFER
    BUFFER = ""
    return buf
}

function update_view_print_cell(logic_row_i, row_i, col_i,       h, _size){
    cord = row_i KSEP col_i

    if (cur_col == col_i) h = 1

    # if (highlight[ cord ]) h = 1

    if (h == 1) buffer_append( sprintf("%s",UI_TEXT_BOLD UI_FG_BLUE UI_TEXT_REV ) )

    if (logic_row_i == cur_row) {
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

    if ((h == 1) && ( logic_row_i != cur_row )) buffer_append( sprintf( UI_END ) )
    buffer_append( sprintf( UI_END ) )
}

BEGIN{
    NEWLINE = "\n"
    counter = 1
}

function update_view(           row_i, col_i, start_row){
    start_row = int( (cur_row - 2) / max_row_in_page) * max_row_in_page + 2

    buffer_append( sprintf("FILTER: %s" NEWLINE, filter[cur_col]) )

    buffer_append( sprintf("%s %s %s" NEWLINE, counter++, cur_row, cur_col) )
    buffer_append( sprintf("%s     ", UI_TEXT_UNDERLINE UI_TEXT_BOLD) )
    for (col_i=1; col_i<=table_col; col_i++) {
        # update_view_print_cell( 1, col_i )
        buffer_append( sprintf( "%s  ", str_pad_right( data[ 1 KSEP col_i ], col_max[ col_i ], data_wlen[ 1 KSEP col_i ] ) ) )
    }
    buffer_append( sprintf("%s", UI_END) )
    buffer_append( sprintf( NEWLINE ) )

    for (row_i = start_row; row_i <= start_row + max_row_in_page; row_i ++) {
        if (row_i > table_row) break
        buffer_append( sprintf("%s", str_pad_right(row_i-1, 5)) )
        for (col_i=1; col_i<=table_col; col_i++) {
            update_view_print_cell( row_i, row_i, col_i )
            buffer_append( sprintf( "%s", "  " ) )
        }
        buffer_append( sprintf("%s" NEWLINE, UI_END) )
    }
    # printf( NEWLINE )

    send_msg_update( buffer_clear() )
    BUFFER = ""
}

# EndSection

# Section: logical table

function update_logical_table(  _cord, _elem, row_i, col_i){
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
    cur_row = 2
}

function update_logic_view(           logic_row_i, row_i, col_i, start_row){
    start_row = int( (cur_row - 2) / max_row_in_page) * max_row_in_page + 2
    
    buffer_append( sprintf("FILTER: %s" NEWLINE, filter[cur_col]) )
    
    # buffer_append( sprintf("%s %s %s" NEWLINE, counter++, cur_row, cur_col) )
    buffer_append( sprintf("%s     ", UI_TEXT_UNDERLINE UI_TEXT_BOLD) )
    for (col_i=1; col_i<=table_col; col_i++) {
        if (col_max[ col_i ] > available_cols_len) {
            buffer_append( sprintf( "%s", str_pad_right( data[ 1 KSEP col_i ], available_cols_len + 6, data_wlen[ 1 KSEP col_i ] ) ) )
        }else{
            buffer_append( sprintf( "%s  ", str_pad_right( data[ 1 KSEP col_i ], col_max[ col_i ], data_wlen[ 1 KSEP col_i ] ) ) )
        }
        # buffer_append( sprintf( "%s  ", str_pad_right( data[ 1 KSEP col_i ], col_max[ col_i ], data_wlen[ 1 KSEP col_i ] ) ) )
    }
    buffer_append( sprintf("%s", UI_END) )
    buffer_append( sprintf( NEWLINE ) )
    for (logic_row_i = start_row; logic_row_i <= start_row + max_row_in_page; logic_row_i ++) {
        if (logic_row_i > logic_table_row) break
        row_i = logic_table[ logic_row_i ]
        buffer_append( sprintf("%s", str_pad_right(row_i-1, 5)) )
        for (col_i=1; col_i<=table_col; col_i++) {
            update_view_print_cell( logic_row_i, row_i, col_i )
            # buffer_append( sprintf( "%s", "  " ) )
        }
        buffer_append( sprintf("%s" NEWLINE, UI_END) )
    }
    buffer_append( sprintf("SELECT: %s" NEWLINE, data[ cur_row KSEP cur_col ]) )
    # printf( NEWLINE )

    send_msg_update( buffer_clear() )
    BUFFER = ""
}


# EndSection

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

    update_logical_table()
}

# function send_msg(channel, msg){
#     # gsub("\n", "\001", msg)
#     print(channel)
#     print(msg)
#     fflush()
# }

function send_msg_update(msg){
    # mawk
    if (RS == "\n") {
        # gsub("\n", "\001", msg)
        gsub(/\n/, "\001", msg)
    }

    printf("%s %s %s" RS, "UPDATE", max_col_size, max_row_size)
    printf("%s" RS, msg)

    fflush()
}

function send_env(var, value){
    # mawk
    if (RS == "\n") {
        # gsub("\n", "\001", msg)
        gsub(/\n/, "\001", value)
        printf("%s %s\n", "ENV", var)
        printf("%s\n", value)
    } else{
        printf("%s %s\001", "ENV", var)
        printf("%s\001", value)
    }
    # printf("%s %s\001", "ENV", var)
    # printf("%s\001", value)
    fflush()
}

# Section: Get data

function update_width_height(width, height) {
    max_row_size = height
    max_col_size = width
    # TODO: if row less than 10 rows, we should exit.
    max_row_in_page = max_row_size - 10
}

NR==1 {
    update_width_height( $2, $3 )
}

NR==2 {
    parse_data($0)
    # update_view()
}

# EndSection

BEGIN {
    final_command = ""
    filter_edit_state = false
    # filter
}

function exit_with_elegant(command, item){
    final_command = command
    exit(0)
}

# Section: handle the view

NR>2 {

    command = $1
    command = str_trim( command )

    if (command == "VIEW") {
        update_width_height( $2, $3 )
        update_logic_view()
    } else if (command == "CHAR") {
        char_type = $2
        char_value = $3

        if (filter_edit_state == true) {
            if (char_value == "ENTER") {
                filter_edit_state = false
                update_logical_table()
            } else {
                if (char_type == "ascii-delete") {
                    cur_filter = filter[ cur_col ]
                    filter[ cur_col ] = substr(cur_filter, 1, length(cur_filter) - 1)
                    # trigger filter: invocation cost much...
                } else {
                    cur_filter = filter[ cur_col ]
                    filter[ cur_col ] = cur_filter char_value
                }
            }
        } else {
            if (char_type == "ascii-space") {
                filter_edit_state = true
            } else if (char_value == "ENTER") {
                exit_with_elegant( "enter" )
                # filter_edit_state = false
            } else if (char_value == "c") {
                # create
                exit_with_elegant( "create" )
            } else if (char_value == "r") {
                # retriev
                exit_with_elegant( "retrieve" )
            } else if (char_value == "u") {
                # update
                exit_with_elegant( "update" )
            } else if (char_value == "d") {
                # delete
                exit_with_elegant( "delete" )
            } else if (char_value == "e") {
                # edit
                exit_with_elegant( "edit" )
            } else if (char_value == "f") {
                # refresh
                exit_with_elegant( "refresh" )
            } else if (char_value == "p") {
                # previous page
                cur_row = cur_row + max_row_in_page
                cur_row = ((cur_row - 2) % logic_table_row + 2)
                # update_logical_table()
            } else if (char_value == "n") {
                cur_row = cur_row - max_row_in_page
                cur_row = ((cur_row - 2) % logic_table_row + 2)
                cur_row = ((cur_row + logic_table_row - 2) % logic_table_row +2 )
                # update_logical_table()
            } else if (char_value == "UP") {
                cur_row = cur_row - 1
                if (cur_row <= 1) cur_row = logic_table_row
                # update_logical_table()
            } else if (char_value == "DN") {
                if (cur_row <= 1) {
                    cur_row = 2
                } else {
                    cur_row = cur_row + 1
                    if (cur_row > logic_table_row) cur_row = 2
                }
                # update_logical_table()
            } else if (char_value == "LEFT" ) {
                # debug_file("RECV" command)
                cur_col = cur_col - 1
                if (cur_col <= 0) cur_col = table_col
                # update_logical_table()
            } else if (char_value == "RIGHT") {
                if (cur_col <= 0) {
                    cur_col = 1
                } else {
                    cur_col = cur_col + 1
                    if (cur_col > table_col) cur_col = 1
                }
                # update_logical_table()
            }
        }
    }
}

END {
    if (final_command != "") {
        send_env("___X_CMD_UI_TABLE_final_command", final_command)
        send_env("___X_CMD_UI_TABLE_CUR_ROW", cur_row)
        send_env("___X_CMD_UI_TABLE_CUR_COL", cur_col)
        send_env("___X_CMD_UI_TABLE_CUR_LINE", lines[cur_row])
    }
}

# EndSection
