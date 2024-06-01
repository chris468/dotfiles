export def --env apply [
    --update (-u): any
    --delete (-d): list<string>
] {
    try {
        load-env ($update | default {})
    } catch {
        error make { msg: $"Failed to make update: $($update | default {} | table -e)"}
    }

    try {
        hide-env -i ...($delete | default [])
    } catch {
        error make { msg: $"Failed to make delete: $($delete | default [] | table -e)"}
    }
}


export def --env capture [
    --shell (-s): string = ""
    # Shell to use.
    --arguments (-a): list<string> = []
    # Additional arguments to shell.
    --verbose
    # Enable verbose output
] -> record {
    let $script = $in

    def parse-env [] {
        $in
            | parse "{name}={value}"
            | transpose --header-row --as-record
            | reject -i PWD
    }

    def default_shell [] {
        if (sys host).name == "Windows" {
            'C:\Program Files\Git\bin\bash.exe'
        } else {
            (which bash).path | first
        }
    }

    def changes [
        original, 
        updated
    ] {
        {
            updates: ($updated
                | reject ...($updated
                    | columns 
                    | where { |it| ($updated | get $it) == ($original | get -i $it) }
                )
            )

            deletes: ($original
                | columns
                | where { $in not-in ($updated | columns) }
            )
        }
    }

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
            original: ($in | first | str trim | split row "\u{0}" | parse-env)
            new: ($in | last | str trim | split row "\u{0}" | parse-env)
        }
    )

    let $changes = (changes $captured_env.original $captured_env.new)

    if $verbose {
        print ($changes | table -e)
    }

    apply -u $changes.updates -d $changes.deletes
}
