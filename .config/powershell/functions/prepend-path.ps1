function prepend-path([String[]]$Paths, [Switch]$Persist) {
    $scopes = if ($persist) {("User","Process")} else {("Process")}

    foreach ($scope in $scopes) {
        [System.Collections.ArrayList]$pathList = [System.Environment]::GetEnvironmentVariable('PATH', $scope).split(';')

        for ($i = $Paths.Length - 1; $i -ge 0; $i--) {
            $p=(Resolve-Path $Paths[$i]).Path

            if (!$pathList.Contains($p)) {
                $pathList.Insert(0, $p)
            }
        }
        $updatedPath=$pathList -join ';'
        [System.Environment]::SetEnvironmentVariable('PATH', $updatedPath, $scope)
    }
}
