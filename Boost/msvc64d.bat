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
SET "INST_DIR=%BUILDROOT%\Boost\Boost64d"
IF EXIST %INST_DIR% RD /S /Q %INST_DIR%
CALL %SCRIPTROOT%\virgin.bat backup
SET CWD=%CD%
CALL "C:\Program Files (x86)\Microsoft Visual Studio 10.0\VC\bin\amd64\vcvars64.bat"
IF EXIST %SOURCEROOT%\Boost RD /S /Q %SOURCEROOT%\Boost
MD %SOURCEROOT%\Boost
CD %SOURCEROOT%\Boost
"C:\Program Files\7-Zip\7z.exe" x T:\_compressed_sources\boost-1.53.7z
SET "PATH=%BUILDROOT%\Boost\bjam64\bin;%PATH%"
@ECHO OFF
bjam -j4 -q --with-system --with-date_time --toolset=msvc --layout=system --prefix=%INST_DIR% link=shared runtime-link=shared variant=debug debug-symbols=on threading=multi address-model=64 host-os=windows target-os=windows embed-manifest=on architecture=x86 warnings=off warnings-as-errors=off "cflags=/Zi /favor:blend" "linkflags=/NOLOGO /DEBUG /INCREMENTAL:NO" install
IF ERRORLEVEL 1 GOTO FAIL
:: Copy debug symbols
FOR /R .\ %%X IN (boost_*.pdb) DO (
	XCOPY /Y /Q /I %%X %INST_DIR%\lib\
)
XCOPY /Y /Q %SOURCEROOT%\Boost\*.jam %INST_DIR%\
COPY /Y %SOURCEROOT%\Boost\Jamroot %INST_DIR%\
GOTO CLEANUP
:END
CALL %SCRIPTROOT%\virgin.bat restore