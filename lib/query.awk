INPUT==0{
    if ($0 == "---") {
        INPUT=1
    }
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