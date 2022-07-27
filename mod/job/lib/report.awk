$1=="sart:"{
    $1=""
    log_debug("job", "Start: " $0)
    next
}

$1=="exit:"{
    code=$2;            $1=$2=""
    if (code == 0) {
        log_info("job", "Success: " $0)
        success ++
    } else {
        log_warn("job", sprintf("Fail: [code=%s] %s", code, $0))
        failure ++
    }
    next
}

{
    print $0
}

END{
    if (failure > 0) {
        total = success + failure
        log_warn( "job", sprintf( "Total: %s  Pass: %s   Fail: %s", total, success, failure ) )
        exit( 1 )
    } else {
        log_info( "job", sprintf( "Total: %s  All Passed!", total ) )
        exit( 0 )
    }

}
