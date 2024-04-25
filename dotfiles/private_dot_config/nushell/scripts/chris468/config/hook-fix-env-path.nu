use ../util/env "hook add"

export def --env main [] {
    let hook = {
        condition: { ($env.PATH | describe) == string }
        code: { $env.PATH = (do $env.ENV_CONVERSIONS.PATH.from_string $env.PATH) }
    }

    hook add hooks.pre_prompt $hook
    hook add hooks.env_change.PWD $hook
}
