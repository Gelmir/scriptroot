function End-Build ([ValidateNotNullOrEmpty()][bool]$result = $true) {
    Set-Location -Path "$cwd"

    if (-not $result) {
        Write-Warning "`r`n`r`nBuild failed, leaving source tree as is"
    } else {
        Remove-Item -Path "$env:SOURCEROOT\$libname" -Force -Recurse
    }

    Env-Restore $envBackup
    exit
}

function Check-ReturnCode ([ValidateNotNullOrEmpty()][bool]$result) {
    if (-not $result) {
        End-Build $result
    }
}