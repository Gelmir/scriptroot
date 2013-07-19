@ECHO OFF
GOTO BEGIN
:CLEANUP
CD %CWD%
IF EXIST %SOURCEROOT%\lua RD /S /Q %SOURCEROOT%\lua
GOTO END
:FAIL
ECHO Building failed, leaving source tree as is and dumping custom env vars
CD %CWD%
GOTO END
:BEGIN
IF NOT EXIST %BUILDROOT%\lua MD %BUILDROOT%\lua
SET "INST_DIR=%BUILDROOT%\lua\lua64"
IF EXIST %INST_DIR% RD /S /Q %INST_DIR%
CALL %SCRIPTROOT%\virgin.bat backup
SET CWD=%CD%
CALL "C:\Program Files (x86)\Microsoft Visual Studio 10.0\VC\bin\amd64\vcvars64.bat"
IF EXIST %SOURCEROOT%\lua RD /S /Q %SOURCEROOT%\lua
MD %SOURCEROOT%\lua
CD %SOURCEROOT%\lua
XCOPY /Y /E /Q /I C:\Users\Dayman\Documents\GitHub\lua %SOURCEROOT%\lua\
nmake -f Makefile.nmake
IF ERRORLEVEL 1 GOTO FAIL
nmake -f Makefile.nmake test
IF ERRORLEVEL 1 GOTO FAIL
nmake -f Makefile.nmake install
IF ERRORLEVEL 1 GOTO FAIL
GOTO CLEANUP
:END
CALL %SCRIPTROOT%\virgin.bat restore