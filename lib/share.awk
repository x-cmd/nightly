BEGIN{
    false = 0
    true = 1
}

function update_width_height(width, height) {
    max_row_size = height
    max_col_size = width
    # TODO: if row less than 10 rows, we should exit.
    max_row_in_page = max_row_size - 10
}

function try_update_width_height(text){
    if (text !~ /^R:/) {
        return false
    }

    split(text, arr, ":")
    update_width_height(arr[3], arr[4])
    return true
}

# Section: utilities

function send_update(msg){
    # mawk
    if (ORS == "\n") {
        # gsub("\n", "\001", msg)
        gsub(/\n/, "\001", msg)
    }

    printf("%s %s %s" ORS, "UPDATE", max_col_size, max_row_size)
    printf("%s" ORS, msg)

    fflush()
}

function send_env(var, value){
    # mawk
    if (ORS == "\n") {
        gsub(/\n/, "\001", value)
    }

    printf("%s %s" ORS, "ENV", var)
    printf("%s" ORS, value)
    fflush()
}
# EndSection