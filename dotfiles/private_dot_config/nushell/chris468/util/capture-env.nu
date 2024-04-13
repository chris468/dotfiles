export def --env main [
    --vars (-v): list<string>
    # Names of the environment variables to capture.
    --shell (-s): string = "/bin/sh"
    # Shell to use.
    --arguments (-a): list<string> = []
    # Additional arguments to shell.
] -> record {
    let $script = $in
    with-env  {
        SCRIPT: $script
        PRINT_ENV: $'echo {($vars | each {|$i| [$"\\\"($i)\\\"" $"\\\"\"$($i)\"\\\""] | str join ": " } | str join " ")}'
    } {
        ^$shell ...$arguments -c `
            eval "$SCRIPT"
            echo "<CAPTURE_ENV_BELOW>"
            eval "$PRINT_ENV"
        `
    } | split row "<CAPTURE_ENV_BELOW>" | last | str trim | from nuon | load-env
}
