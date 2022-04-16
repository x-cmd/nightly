
function handle_argument( argstr ){
    argsl = split( argstr, args, "\001" )
}

BEGIN{
    USING_PATTERN_REGEX = 1
    USING_PATTERN_ARR = 2
    USING_PATTERN_ARR_REGEX = 2
}

# Skip Pattern to accelerate
function handle_pattern_extraction( pattern ){
    if (pattern ~ /^./) {
        pattern = "1" pattern
    }

    if (pattern ~ /.**./) {
        mode = USING_PATTERN_REGEX
    else (pattern ~ /.*./) {
        mode = USING_PATTERN_ARR_REGEX
    } else {
        mode = USING_PATTERN_ARR
    }
}

function handle_pattern_map(){

}



INPUT==0{
    if ($0 == "---") {

        handle_argument( argstr )

        INPUT=1
        next
    }
    argstr = argstr $0
}

INPUT==1{
    if (JITER_PRINT_RMATCH == 0){
        _ret = jiter( item, JITER_STACK_FOR_GRID_CHECK )
        if ( _ret == "" ) return false
        if ( match(_ret, keypath) == 0 ) return false
        jiter_save( JITER_STACK_FOR_GRID_CHECK )
        jiter_init()
        JITER_PRINT_RMATCH = 1
    }

    jiter_skip( item )
    printf("%s" sep1, item)

    if ( JITER_SKIP_LEVEL > 0 ) return false
    JITER_PRINT_RMATCH = 0
    jiter_load( JITER_STACK_FOR_GRID_CHECK )
    if ( JITER_CURLEN == 0 ) jiter( item, JITER_STACK_FOR_GRID_CHECK )  # Roll back
    printf(sep2)
    return true
}