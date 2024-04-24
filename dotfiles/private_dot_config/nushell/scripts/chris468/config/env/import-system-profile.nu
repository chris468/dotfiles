use ../../util/env

export def --env main [] {
    if $nu.os-info.name != "windows" {
        'test -f /etc/profile && source /etc/profile' | env capture
    }
}
