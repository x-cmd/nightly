

# Section: consume_ctrl
BEGIN{
    ctrl_rstate_init( COL, 1, 3 )
}

function ctrl(char_type, char_value){


    if (char_value == "LEFT" )                      return ctrl_rstate_dec( COL )
    if (char_value == "RIGHT")                      return ctrl_rstate_inc( COL )
}

function consume_ctrl(  _cmd){
    if (try_update_width_height( $0 ) == true) {
        return
    }

    DATA_HAS_CHANGED = true

    _cmd=$0
    gsub(/^C:/, "", _cmd)
    idx = index(_cmd, ":")
    ctrl(substr(_cmd, 1, idx-1), substr(_cmd, idx+1))
    view()
}
# EndSection



# Section: data
BEGIN{
    # TODO: to delete
    S = "\001"
    L = "\002"

    DATA_MODE_DATA = 1
    DATA_MODE_CTRL = 2
    DATA_MODE = DATA_MODE_DATA
}


NR==1 {  update_width_height( $2, $3 );  }

function handle_item(           i, j, l){
    _key = ""
    for (i=1; i<=NF; ++i) {
        l = data[ _key L ]
        data[ _key S l ] = $i
        _key = _key S $i
    }
}

NR>1 {
    if (DATA_MODE == DATA_MODE_DATA) {
        if ($0 != "---")    handle_item()
        else                DATA_MODE = DATA_MODE_CTRL
    } else {
        consume_ctrl()
    }
}

# EndSection
