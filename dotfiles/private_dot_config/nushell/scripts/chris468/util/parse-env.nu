export def main [] {
    $in
        | parse "{name}={value}"
        | transpose --header-row --as-record
        | reject -i PWD
}


