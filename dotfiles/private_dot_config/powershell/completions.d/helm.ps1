if (Get-Command helm -ErrorAction SilentlyContinue) {
    helm completion powershell | Out-String | Invoke-Expression
}

