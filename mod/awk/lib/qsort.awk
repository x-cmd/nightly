

function _qsort(arr, start, end,  i,j,k,s,t){
    print start "\t" end
    i = start
    j = end
    k = int( (start + end) / 2 )

    s = arr[k]
    while (i<j) {
        while ((arr[i] < s) && (i<j)) { i++; }
        while ((arr[j] > s) && (i<j)) { j--; }
        if (arr[i] > arr[j]) {
            t = arr[i]
            arr[i] = arr[j]
            arr[j] = t
        }
        print i, j, arr[i] , arr[j] , s "  -----"
        parr(arr)
    }

    if (start < i) _qsort(arr, start, i)
    if (i+1 < end) _qsort(arr, i+1, end)
}

function qsort(arrl, arr){
    return _qsort(arr, 1, arrl)
}

function parr(arr, i){
    for (i=1; i<=length(arr); ++i) {
        printf("%s ", arr[i])
    }
    print
}

END{
    arr[1]=1
    arr[2]=5
    arr[3]=9
    arr[4]=11
    arr[5]=6
    qsort(5, arr)
    parr(arr)
}
