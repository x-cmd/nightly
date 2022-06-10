

function _qsort(arr, start, end,  i,j,k,s,t){
    print start "\t" end
    i = start
    j = end
    k = int( (start + end) / 2 )

    s = arr[k]
    while (i<=j) {
        while (arr[i++] < s) {}
        while (arr[j--] > s) {}
        if (i<j) {
            t = arr[i]
            arr[i] = arr[j]
            arr[j] = t
        }
    }

    _qsort(arr, start, i)
    _qsort(arr, i+1, end)
}

function qsort(arrl, arr){
    return _qsort(arr, 1, arrl)
}

END{
    a[1]=1
    a[2]=5
    a[3]=9
    a[4]=11
    a[5]=6
    qsort(5, arr)
    for (i=1; i<=arr; ++i) {
        print arr[i]
    }
}
