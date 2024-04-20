export def --env main [] {
    if $nu.os-info.name != "windows" {
        'test -f /etc/profile && source /etc/profile' | util capture-env
    }
}
