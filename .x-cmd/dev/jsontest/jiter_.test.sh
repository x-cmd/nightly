

xrc awk

# DSL: json_get(_, ".b")

SSS="$(cat default.awk)$(cat json.awk jiter.awk jdict.awk)"

f1(){
    awk "$SSS"'
    {
        if ($0 != "") {
            jiparse(_, $0)
            # print ($0)
        }
    }
    END{
        print json_stringify_format(_, "1", 4)
    }
    '
}

f(){

{
    awk "$SSS
    {
        printf(\"%s\", json_to_machine_friendly(\$0) )
    }" | f1
} <<A
{
    "a": 3,
    "b": [
        3,
        4,
        5,
        6,
        7,
        8
    ],
    "c": {
        "a": 1
    }
}
A
}

time f

