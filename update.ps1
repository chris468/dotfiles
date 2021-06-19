
$git="git -C $PSScriptRoot"

function has_updates {
    & $git fetch origin
    & $git status --porcelain -b | 
}
