function __add_local_paths {
    $local_paths=@(
        "$HOME/.local/bin",
        "$HOME/bin"
    )
    [array]::reverse($local_paths)

     foreach ($p in $local_paths) {
         if ( Test-Path -PathType Container $p ) {
             $env:PATH="$p;$env:PATH"
         }
     }
}

. __add_local_paths
