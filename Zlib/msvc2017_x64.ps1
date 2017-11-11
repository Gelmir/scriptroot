param(
    [Parameter(Mandatory=$true)][ValidateSet("Release", "Debug")][string]$ReleaseType
)

. "..\Get-BatchFile.ps1"
. "..\End-Build.ps1"

<# These vars should be common for all scripts #>
$envBackup = $(Env-Save)
$cwd = $(Get-Location).Path
$libname = "zlib"
$debug_prefix = ""
if ($ReleaseType -eq "Debug") {
    $debug_prefix = "d"
}
<###############################################>

Get-BatchFile "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build\vcvars64.bat"

if ($(Test-Path "$env:BUILDROOT\$libname") -eq $false) {
    New-Item -Path "$env:BUILDROOT\$libname" -ItemType Directory -Force
}

$env:INST_DIR = "$env:BUILDROOT\$libname\${libname}${debug_prefix}_msvc2017_x64"
if ($(Test-Path "$env:INST_DIR") -eq $true) {
    Remove-Item -Path "$env:INST_DIR" -Force -Recurse
}
New-Item -Path "$env:INST_DIR" -ItemType Directory -Force

if ($(Test-Path "$env:SOURCEROOT\$libname") -eq $true) {
    Remove-Item -Path "$env:SOURCEROOT\$libname" -Force -Recurse
}
New-Item -Path "$env:SOURCEROOT\$libname" -ItemType Directory -Force
Set-Location -Path "$env:SOURCEROOT\$libname"

& "7z" @("x", "$env:ARCHIVES\zlib-1.2.11.7z", "-o$env:SOURCEROOT\$libname")
Check-ReturnCode $?

(Get-Content -Path ".\win32\Makefile.msc") `
    -replace "(^ASFLAGS = ).*(\$\(LOC\))", '$1$2 -nologo' `
    -replace "(^AS = ).*", '$1ml64' |
    Out-File -Force -FilePath ".\win32\Makefile.msc"

$jomDefines = ""
if ($ReleaseType -eq "Release") {
    (Get-Content -Path ".\win32\Makefile.msc") `
        -replace "(^CFLAGS\s+= ).*(\$\(LOC\))", '$1-nologo -MD -O2 -W3 -favor:blend -GL -GR- -Y- -MP -EHs-c- $2' `
        -replace "(^LDFLAGS = ).*", '$1-nologo -incremental:no -opt:ref -opt:icf=5 -ltcg' `
        -replace "(^ARFLAGS = .*)", '$1 -ltcg' |
        Out-File -Force -FilePath ".\win32\Makefile.msc"

        $jomDefines = "LOC=`"-DASMV -DASMINF -DNDEBUG -I.`""
} else { # Debug
    (Get-Content -Path ".\win32\Makefile.msc") `
        -replace "(^CFLAGS\s+= ).*(\$\(LOC\))", '$1-nologo -MDd -Od -W3 -favor:blend -GR- -Y- -MP -FS -EHs-c- $2' `
        -replace "(^LDFLAGS = ).*", '$1-nologo -incremental:no -debug' |
        Out-File -Force -FilePath ".\win32\Makefile.msc"

        $jomDefines = "LOC=`"-DASMV -DASMINF -DDEBUG -I.`""
}

& jom @("-nologo", "-j8", "-f", "`".\win32\Makefile.msc`"", "AS=ml64", "$jomDefines", "OBJA=`"inffasx64.obj gvmat64.obj inffas8664.obj`"")
Check-ReturnCode $?
& jom @("-nologo", "-j1", "-f", "`".\win32\Makefile.msc`"", "test")
Check-ReturnCode $?

foreach ($dir in @("$env:INST_DIR\bin\", "$env:INST_DIR\lib\", "$env:INST_DIR\include\")) {
    New-Item -Path "$dir" -ItemType Directory -Force | Out-Null
}
Copy-Item -Force ".\*.dll" "$env:INST_DIR\bin\"
Copy-Item -Force ".\*.lib" "$env:INST_DIR\lib\"
Copy-Item -Force ".\zconf.h" "$env:INST_DIR\include\"
Copy-Item -Force ".\zlib.h" "$env:INST_DIR\include\"

End-Build