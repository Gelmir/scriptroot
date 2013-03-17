@ECHO OFF
IF NOT EXIST %BUILDROOT%\Boost MD %BUILDROOT%\Boost
SET "INST_DIR=%BUILDROOT%\Boost\Boost"
IF EXIST %INST_DIR% RD /S /Q %INST_DIR%
CALL %SCRIPTROOT%\virgin.bat backup
SET CWD=%CD%
CALL "C:\Program Files (x86)\Microsoft Visual Studio 10.0\VC\bin\vcvars32.bat"
IF EXIST %SOURCEROOT%\Boost RD /S /Q %SOURCEROOT%\Boost
MD %SOURCEROOT%\Boost
CD %SOURCEROOT%\Boost
"C:\Program Files\7-Zip\7z.exe" x T:\_compressed_sources\boost-1.50.7z
SET "PATH=%PATH%;%BUILDROOT%\Boost\bjam64\bin"
@ECHO OFF
bjam -j3 -q --with-system --with-date_time --toolset=msvc --layout=system --prefix=%INST_DIR% link=shared runtime-link=shared variant=release debug-symbols=off threading=multi address-model=32 host-os=windows target-os=windows embed-manifest=on architecture=x86 inlining=full warnings=off warnings-as-errors=off optimization=speed "cflags=/O2 /GL /MP /arch:SSE" "linkflags=/NOLOGO /OPT:REF /OPT:ICF=5 /LTCG" install
COPY /Y *.jam %INST_DIR%
COPY /Y Jamroot %INST_DIR%
CD ..\
RD /S /Q boost
SET INST_DIR=
CD %CWD%
CALL %SCRIPTROOT%\virgin.bat restore