-- vim: ft=lua tw=140

globals = { "vim" }

read_globals = {
    "describe",
    "it",
    "before_each",
    "after_each",
    "setup",
    "teardown",
    "assert",
    "spy",
    "mock",
    "stub"
}

ignore = {
    "unused_args"
}

files["tests/**/*.lua"] = {
    std = "+busted"
}
