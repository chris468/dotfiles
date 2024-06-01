export def --env setup [] {
    const init = "~/.config/nushell/scripts/_lib/.oh-my-posh.nu"
    if ($init | path exists ) {

        $env.PROMPT_INDICATOR_VI_INSERT = ""
        $env.PROMPT_INDICATOR_VI_NORMAL = ""

        source $init
    }
}

