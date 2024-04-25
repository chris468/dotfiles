use ../util/env "hook add"

export def --env main [] {
    let hook = {
        condition: { "TMUX" in $env }
        code: { update-tmux-environment }
    }

    hook add hooks.pre_execution $hook

    def --env update-tmux-environment [] {
        let updates = tmux show-environment
            | lines
            | {
                remove: ($in | where { str starts-with "-" } | str substring 1..)
                add: ($in
                    | where { not ($in | str starts-with "-") }
                    | parse "{name}={value}"
                    | transpose --as-record --header-row
                )
        }

        for r in $updates.remove { hide-env -i $r }

        load-env $updates.add
    }
}

