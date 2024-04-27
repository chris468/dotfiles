use _lib oh-my-posh

export def --env setup [] {
    oh-my-posh setup

    $env.config.hooks.pre_prompt = ($env.config.hooks.pre_prompt | append [
        'if (term size).columns >= 90 { $env.POSH_WIDE = 1 } else { $env.POSH_WIDE = 0 }'
    ])
}
