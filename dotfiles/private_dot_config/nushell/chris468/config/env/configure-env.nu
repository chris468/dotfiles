export def --env set [
    name:string,
    value:string
] {
    load-env { $name: $value }
}

export def --env unset [
    name:string
] {
    hide-env -i $name
}

export def --env prepend [
  name:string,
  ...value:string
] {
    let $original = $env | get -i $name
    let $original = match ($original | describe) {
        nothing => []
        list<string> => $original
        string => ($original | split row (char esep) | path expand --no-symlink)
        _ => (error make {msg: "Only string and list of string work"})
    }

    load-env {
        $name: ($value
            | each {|v| if $v not-in $original { $v } }
            | append $original
        )
    }
}
