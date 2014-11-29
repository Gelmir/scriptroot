@ECHO OFF
GOTO BEGIN
:CLEANUP
CD %CWD%
SET INST_DIR=
IF EXIST %SOURCEROOT%\libtorrent RD /S /Q %SOURCEROOT%\libtorrent
GOTO END
:FAIL
ECHO Building failed, leaving source tree as is and dumping custom env vars
CD %CWD%
IF DEFINED INST_DIR ECHO INST_DIR = %INST_DIR%
IF DEFINED LOG ECHO LOG = %LOG%
SET INST_DIR=
GOTO END
:BEGIN
IF NOT EXIST %BUILDROOT%\libtorrent MD %BUILDROOT%\libtorrent
SET "INST_DIR=%BUILDROOT%\libtorrent\libtorrent64_0"
IF EXIST %INST_DIR% RD /S /Q %INST_DIR%
CALL %SCRIPTROOT%\virgin.bat backup
SET CWD=%CD%
CALL "C:\Program Files (x86)\Microsoft Visual Studio 11.0\VC\bin\x86_amd64\vcvarsx86_amd64.bat"
IF EXIST %SOURCEROOT%\libtorrent RD /S /Q %SOURCEROOT%\libtorrent
MD %SOURCEROOT%\libtorrent
CD %SOURCEROOT%\libtorrent
"C:\Program Files\7-Zip\7z.exe" x %ARCHIVES%\libtorrent-0.16.18.7z -o%SOURCEROOT%\libtorrent
SET "PATH=%BUILDROOT%\Boost\bjam64\bin;%PATH%"
bjam -j4 -q --toolset=msvc --prefix=%INST_DIR% boost=system boost-link=shared link=shared runtime-link=shared variant=release debug-symbols=off resolve-countries=on full-stats=on export-extra=on ipv6=on character-set=unicode geoip=static encryption=openssl windows-version=vista threading=multi address-model=64 host-os=windows target-os=windows embed-manifest=on architecture=x86 warnings=off warnings-as-errors=off inlining=full optimization=speed "cflags=/O2 /GL /favor:blend" "linkflags=/NOLOGO /OPT:REF /OPT:ICF=5 /LTCG" "include=%BUILDROOT%\OpenSSL\OpenSSL64\include" "include=%BUILDROOT%\Boost\Boost64\include" "library-path=%BUILDROOT%\OpenSSL\OpenSSL64\lib" "library-path=%BUILDROOT%\Boost\Boost64\lib" "define=BOOST_ALL_NO_LIB" install
IF ERRORLEVEL 1 GOTO FAIL
GOTO CLEANUP
:END
CALL %SCRIPTROOT%\virgin.bat restore