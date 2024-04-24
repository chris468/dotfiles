export def --env main [
    --update (-u): any
    --delete (-d): list<string>
] {
    try {
        load-env ($update | default {})
    } catch {
        error make { msg: $"Failed to make update: $($update | default {} | table -e)"}
    }

    try {
        hide-env -i ...($delete | default [])
    } catch {
        error make { msg: $"Failed to make delete: $($delete | default [] | table -e)"}
    }
}

