function Script:astrovim {
  try {
    $NVIM_APPNAME = $env:NVIM_APPNAME
  }
  catch {
    Write-Error -ErrorAction Stop "$PSItem"
  }

  try {
    $env:NVIM_APPNAME = "astrovim"
    nvim @args
  }
  finally {
    $env:NVIM_APPNAME = $NVIM_APPNAME
  }
}

astrovim @args
