export def --env main [] {
    const script = "~/.cache/carapace/init.nu"
    if ($script | path exists) {
        source $script
    }
}
