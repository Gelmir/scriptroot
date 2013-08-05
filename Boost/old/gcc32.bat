@ECHO OFF
GOTO BEGIN
:CLEANUP
CD %CWD%
SET INST_DIR=
IF EXIST %SOURCEROOT%\Boost RD /S /Q %SOURCEROOT%\Boost
GOTO END
:FAIL
ECHO Building failed, leaving source tree as is and dumping custom env vars
CD %CWD%
IF DEFINED INST_DIR ECHO INST_DIR = %INST_DIR%
SET INST_DIR=
GOTO END
:BEGIN
IF NOT EXIST %BUILDROOT%\Boost MD %BUILDROOT%\Boost
SET "INST_DIR=%BUILDROOT%\Boost\Boost_G"
IF EXIST %INST_DIR% RD /S /Q %INST_DIR%
CALL %SCRIPTROOT%\virgin.bat backup
SET CWD=%CD%
IF EXIST %SOURCEROOT%\Boost RD /S /Q %SOURCEROOT%\Boost
MD %SOURCEROOT%\Boost
CD %SOURCEROOT%\Boost
"C:\Program Files\7-Zip\7z.exe" x %ARCHIVES%\boost-1.54.7z -o%SOURCEROOT%\Boost
SET "PATH=%BUILDROOT%\Boost\bjam64\bin;%PATH%"
bjam -j4 -q --abbreviate-paths --with-system --toolset=gcc --layout=system --prefix=%INST_DIR% link=shared runtime-link=shared variant=release debug-symbols=off threading=multi host-os=windows target-os=windows warnings=off warnings-as-errors=off inlining=on optimization=off "cflags=-O2 -mtune=generic -mmmx -msse -msse2 -fomit-frame-pointer -fpredictive-commoning -pipe  -finline-small-functions -fstack-protector-all" "linkflags=-fstack-protector-all -Wl,-O1 -Wl,--as-needed -Wl,-s -shared-libgcc -Wl,--nxcompat -Wl,--dynamicbase" install
IF ERRORLEVEL 1 GOTO FAIL
XCOPY /Y /Q %SOURCEROOT%\Boost\*.jam %INST_DIR%\
COPY /Y %SOURCEROOT%\Boost\Jamroot %INST_DIR%\
GOTO CLEANUP
:END
CALL %SCRIPTROOT%\virgin.bat restore