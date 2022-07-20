
command awk -f default.awk -f json.awk -f jqparse.awk -f j2y.awk -f j2y.test.awk <<A
{
    "a": 3,
    "b": 4,
    "c": 6,
    "d": [ 1, 2, "jhi", {
        "a": 1,
        "b": 2
    } ],
    "e": { "a": 1 }
}
A