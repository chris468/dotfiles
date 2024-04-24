use ../changes.nu
use apply.nu
use parse.nu


def default_shell [] {
    if (sys).host.name == "Windows" {
        'C:\Program Files\Git\bin\bash.exe'
    } else {
        (which bash).path | first
    }
}

export def --env main [
    --shell (-s): string = ""
    # Shell to use.
    --arguments (-a): list<string> = []
    # Additional arguments to shell.
    --verbose
    # Enable verbose output
] -> record {
    let $script = $in
    let captured_env = (with-env  {
            SCRIPT: $script
        } {
            ^(if $shell == "" { default_shell } else { $shell }) ...$arguments -c `
                env -0
                echo "<CAPTURE_ENV>"
                eval "$SCRIPT"
                echo "<CAPTURE_ENV>"
                env -0
            `
        } | split row "<CAPTURE_ENV>"
        | {
            original: ($in | first | str trim | split row "\u{0}" | parse)
            new: ($in | last | str trim | split row "\u{0}" | parse)
        }
    )

    let $changes = (changes $captured_env.original $captured_env.new)

    if $verbose {
        print ($changes | table -e)
    }

    apply -u $changes.updates -d $changes.deletes
}
