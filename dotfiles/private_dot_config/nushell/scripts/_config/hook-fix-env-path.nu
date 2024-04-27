use chris468 util env "hook add"

export def --env main [] {
    let hooks = [{
        condition: { ($env.PATH? | describe) == string }
        code: { $env.PATH = (do $env.ENV_CONVERSIONS.PATH.from_string $env.PATH) }
    } {
        condition: { ($env.Path? | describe) == string }
        code: { $env.Path = (do $env.ENV_CONVERSIONS.Path.from_string $env.Path) }
    }]

    for hook in $hooks {
        hook add hooks.pre_prompt $hook
        hook add hooks.env_change.PWD $hook
    }
}
