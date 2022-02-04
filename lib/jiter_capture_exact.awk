# Section: EXACT

BEGIN{
    # jiter_capture_all_setup( json_kp_regex("work", "*", "handle", "a") )
}

{
    if (jiter_capture_exect(token, json_kp("work", 1, "handle", "a"))){
        return
    }

    _[ json_kp( "a" KSEP "b" ) ]
}

# EndSection
