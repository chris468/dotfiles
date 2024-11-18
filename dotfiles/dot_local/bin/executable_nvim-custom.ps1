function Script:lazyvim {
  try {
    $NVIM_APPNAME = $env:NVIM_APPNAME
  }
  catch {
    Write-Error -ErrorAction Stop "$PSItem"
  }

  try {
    $env:NVIM_APPNAME = "nvim-custom"
    nvim @args
  }
  finally {
    $env:NVIM_APPNAME = $NVIM_APPNAME
  }
}

lazyvim @args
