@ECHO OFF
GOTO BEGIN
:CLEANUP
CD %CWD%
SET INST_DIR=
SET VisualStudioVersion=
IF EXIST %SOURCEROOT%\icu RD /S /Q %SOURCEROOT%\icu
GOTO END
:FAIL
ECHO Building failed, leaving source tree as is and dumping custom env vars
CD %CWD%
IF DEFINED INST_DIR ECHO INST_DIR = %INST_DIR%
SET INST_DIR=
SET VisualStudioVersion=
GOTO END
:BEGIN
IF NOT EXIST %BUILDROOT%\icu\icu64 MD %BUILDROOT%\icu\icu64
SET "INST_DIR=%BUILDROOT%\icu\icu64"
IF EXIST %INST_DIR% RD /S /Q %INST_DIR%
CALL %SCRIPTROOT%\virgin.bat backup
SET CWD=%CD%
CALL "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build\vcvars64.bat"
IF EXIST %SOURCEROOT%\icu RD /S /Q %SOURCEROOT%\icu
MD %SOURCEROOT%\icu
CD %SOURCEROOT%\icu
"C:\Program Files\7-Zip\7z.exe" x %ARCHIVES%\icu-58.2.7z -o%SOURCEROOT%\icu
IF ERRORLEVEL 1 GOTO FAIL
:: Would like to edit CFLAGS and LFLAGS, but it really painful
msbuild.exe /m .\source\allinone\allinone.sln /p:Configuration="Release" /p:Platform="x64" /p:PlatformToolset=v141
IF ERRORLEVEL 1 GOTO FAIL
SET "PATH=.\bin64;%PATH%"
CALL .\source\allinone\icucheck.bat x64 Release
::IF ERRORLEVEL 1 GOTO FAIL
:: Install target
FOR %%X IN (bin64 lib64 include) DO (
  XCOPY /Q /Y /I /E %SOURCEROOT%\icu\%%X %INST_DIR%\%%X\
)
GOTO CLEANUP
:END
CALL %SCRIPTROOT%\virgin.bat restore