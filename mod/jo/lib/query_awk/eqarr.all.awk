INPUT==0{
    if ($0 == "---") {
        handle_argument( argstr )
        INPUT=1
        next
    }
    argstr = argstr $0
}

INPUT==1{
    jiter_eqarr_print( $0, patarrl, patarr, "", "\n")
}
