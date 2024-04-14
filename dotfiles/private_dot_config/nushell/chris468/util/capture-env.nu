def parse-env [] {
    $in | (
        split row "\u{0}"
        | parse "{name}={value}"
        | transpose --header-row --as-record
        | reject -i PWD
    )
}
export def --env main [
    --shell (-s): string = "/bin/sh"
    # Shell to use.
    --arguments (-a): list<string> = []
    # Additional arguments to shell.
    --verbose
    # Enable verbose output
] -> record {
    let $script = $in
    let result = (with-env  {
            SCRIPT: $script
        } {
            ^$shell ...$arguments -c `
                env -0
                echo "<CAPTURE_ENV>"
                eval "$SCRIPT"
                echo "<CAPTURE_ENV>"
                env -0
            `
        } | split row "<CAPTURE_ENV>"
        | {
            original: ($in | first | str trim | parse-env)
            updated: ($in | last | str trim | parse-env)
        }
    )
    let updates = ($result.updated
        | columns
        | where {|it| ($result.updated | get $it) != ($result.original | get -i $it) }
    )

    if not ($updates | is-empty) {
        if $verbose {
            print (
                $updates | each { |it| {
                    variable:$it
                    original:($result.original | get -i $it)
                    updated:($result.updated | get $it)
                } }
            )
        }
        load-env ($result.updated | select ...$updates)
    }
}
