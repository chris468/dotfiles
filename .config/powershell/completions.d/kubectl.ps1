if (Get-Command kubectl -ErrorAction SilentlyContinue) {
    helm completion powershell | Out-String | Invoke-Expression
}

