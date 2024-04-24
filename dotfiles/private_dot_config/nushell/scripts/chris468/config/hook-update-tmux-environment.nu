use ../util/add-hook.nu
use ../util/env

export def --env main [] {
    let hook = {
        condition: { "TMUX" in $env }
        code: { update-tmux-environment }
    }

    add-hook hooks.pre_execution $hook

    def --env update-tmux-environment [] {
        let updates = tmux show-environment
            | lines
            | {
                remove: ($in | where { str starts-with "-" } | str substring 1..)
                add: ($in | where { not ($in | str starts-with "-") } | env parse)
        }

        for r in $updates.remove { hide-env -i $r }

        load-env $updates.add
    }
}

