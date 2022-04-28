INPUT==1{
    _item_arrl = json_split2tokenarr( _item_arr, $0 )
    for (_i=1; _i<=_item_arrl; ++_i) {
        jiter_regexarr_print( _item_arr[_i],  patarrl, patarr, "", "")
    }
}
