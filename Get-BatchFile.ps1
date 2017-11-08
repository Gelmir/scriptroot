<#
    PS functions for managing environment
#>

function Get-BatchFile ($file) {
    $cmd = "`"$file`" & set"
    cmd /c $cmd | Foreach-Object {
        $p, $v = $_.split('=')
        if ($p -and $v) {
            Set-Item -Path env:$p -Value $v
        }
    }

    # Setup our own additional paths
    $env:Path += ";C:\Program Files\7-Zip"
    $env:Path += ";$env:BUILDROOT\jom"
}

function Env-Save () {
    Get-ChildItem env:*
}

function Env-Restore ($from) {
    Remove-Item env:*
    $from | ForEach-Object { Set-Content Env:$($_.Name) $_.Value }
}