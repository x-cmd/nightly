
END {
    result = table[ jqu(PKG_NAME), jqu("hook"), jqu(SCRIPT) ]
    if (result == "") {
        exit(1)
    } else {
        print RAWPATH "/" PKG_NAME "/.x-cmd/" juq(result)
        exit(0)
    }
}
