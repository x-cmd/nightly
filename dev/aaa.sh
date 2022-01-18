f(){
    while read -r l; do
        echo "$l"
        i=$((i+1))
        [ "$i" = 2 ] && break
    done | {
        while read -r a; do
            echo "$a"
            
        done
        echo "exit already"
        exit
    }
}

g(){

    (
        $SHELL -c 'echo $PPID'
        while read -r l; do
            echo "$l"
        done
    ) | {
        read -r pid
        echo "ccc $pid"
        while read -r a; do
            echo "$a"
            i=$((i+1))
            [ "$i" = 2 ] && break    
        done
        echo "exit already |$!|"
        kill -SIGPIPE "$pid"

        
    }
}

h(){
    echo $$
    $SHELL -c 'echo $PPID'


    (
        echo $$
        $SHELL -c 'echo $PPID'
    )
}

h


