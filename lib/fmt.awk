function jiter_print( obj, item ){
    if (item ~ /^$/)    return
    if (item ~ /^:$/) {
        printf( "%s ", item )
    } else if (item ~ /^,$/) {
        printf( "%s\n%s", item ,JITER_PRINT_INDENT)
    } else if (item ~ /^[tfn"0-9+-]/)  #"        # (item !~ /^[\{\}\[\]]$/)
    {
        printf( "%s", item )
    } else if (item ~ /^[\[\{]$/) { # }
        JITER_LEVEL ++
        obj[ JITER_LEVEL T_INDENT ] = JITER_PRINT_INDENT
        obj[ JITER_LEVEL ] = JITER_STATE

        JITER_PRINT_INDENT = JITER_PRINT_INDENT INDENT
        JITER_STATE = item
        printf("%s\n%s",item, JITER_PRINT_INDENT)
    } else {
        JITER_PRINT_INDENT = obj[ JITER_LEVEL T_INDENT ]
        JITER_STATE = obj[ JITER_LEVEL ]
        JITER_LEVEL --
        printf("\n%s%s", JITER_PRINT_INDENT, item)
    }
}

BEGIN{
    T_INDENT = "\003"
    if (INDENT == "")  INDENT = "  "
    if ( int(INDENT) > 0 )  INDENT = sprintf("%" int(INDENT) "s", "")
}

{
    jiter_print( _, $0 )
}
