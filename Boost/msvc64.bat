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
SET "INST_DIR=%BUILDROOT%\Boost\Boost64"
IF EXIST %INST_DIR% RD /S /Q %INST_DIR%
CALL %SCRIPTROOT%\virgin.bat backup
SET CWD=%CD%
CALL "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build\vcvars64.bat"
IF EXIST %SOURCEROOT%\Boost RD /S /Q %SOURCEROOT%\Boost
MD %SOURCEROOT%\Boost
CD %SOURCEROOT%\Boost
"C:\Program Files\7-Zip\7z.exe" x %ARCHIVES%\boost-1.65.1.7z -o%SOURCEROOT%\Boost
IF EXIST %BUILDROOT%\Boost\bjam64 RD /S /Q %BUILDROOT%\Boost\bjam64
CD .\tools\build
ECHO using msvc : : "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Tools\MSVC\14.10.25017\bin\HostX64\x64\cl.exe" ; > project-config.jam
CALL .\bootstrap.bat
IF ERRORLEVEL 1 GOTO FAIL
.\b2.exe --toolset=msvc architecture=x86 address-model=64 --prefix=%BUILDROOT%\Boost\bjam64 link=shared runtime-link=shared variant=release debug-symbols=off warnings=off warnings-as-errors=off inlining=full optimization=speed "cflags=/O2 /GL /favor:AMD64" "linkflags=/NOLOGO /OPT:REF /OPT:ICF=5 /LTCG" install
IF ERRORLEVEL 1 GOTO FAIL
COPY /Y .\project-config.jam ..\..\
CD ..\..\
SET "PATH=%BUILDROOT%\Boost\bjam64\bin;%PATH%"
@ECHO OFF
bjam -j8 -q --with-system --with-chrono --with-random --with-date_time --toolset=msvc --layout=system --prefix=%INST_DIR% link=shared runtime-link=shared variant=release debug-symbols=off threading=multi address-model=64 host-os=windows target-os=windows embed-manifest=on architecture=x86 warnings=off warnings-as-errors=off inlining=full optimization=speed "cflags=/O2 /GL /favor:blend" "linkflags=/NOLOGO /OPT:REF /OPT:ICF=5 /LTCG" install
IF ERRORLEVEL 1 GOTO FAIL
XCOPY /Y /Q %SOURCEROOT%\Boost\*.jam %INST_DIR%\
COPY /Y %SOURCEROOT%\Boost\Jamroot %INST_DIR%\
GOTO CLEANUP
:END
CALL %SCRIPTROOT%\virgin.bat restore