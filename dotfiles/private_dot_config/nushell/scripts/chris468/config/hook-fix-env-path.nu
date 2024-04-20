use ../util/add-hook.nu

export def --env main [] {
    let hook = {
        condition: { ($env.PATH | describe) == string }
        code: { $env.PATH = (do $env.ENV_CONVERSIONS.PATH.from_string $env.PATH) }
    }

    add-hook hooks.pre_prompt $hook
    add-hook hooks.env_change.PWD $hook
}
