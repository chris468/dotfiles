Param(
    $branch,
    $destination="~/.config/dotfiles",
    $repo="https://github.com/chris468/dotfiles",
    [Parameter(ValueFromRemainingArguments=$true)] $configureOptions
)

$destination = $destination -replace "~","$HOME"

if ( Test-Path "$destination" ) {
    if ( Test-Path "$destination/.git" ) {
        Write-Output "Already installed ($destination already exists)"
    }
    else {
        throw "$destination exists but does not appear to be a git repo"
    }
}
else {
    Write-Output "Cloning dotfiles $repo branch $branch to $destination..."
    git clone "$repo" "$destination"
}

if ( $branch ) {
    Write-Output "Checking out branch $branch..."
    git -C "$destination" checkout $branch
    git -C "$destination" pull
}

Write-Output "`nConfiguring..."
& "$destination/configure-all.ps1" $configureOptions

Write-Output "`nComplete."



