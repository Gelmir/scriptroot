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
SET INST_DIR=
GOTO END
:BEGIN
IF NOT EXIST %BUILDROOT%\libtorrent MD %BUILDROOT%\libtorrent
SET "INST_DIR=%BUILDROOT%\libtorrent\libtorrent64d"
IF EXIST %INST_DIR% RD /S /Q %INST_DIR%
CALL %SCRIPTROOT%\virgin.bat backup
SET CWD=%CD%
CALL "C:\Program Files (x86)\Microsoft Visual Studio 12.0\VC\bin\x86_amd64\vcvarsx86_amd64.bat"
IF EXIST %SOURCEROOT%\libtorrent RD /S /Q %SOURCEROOT%\libtorrent
MD %SOURCEROOT%\libtorrent
CD %SOURCEROOT%\libtorrent
"C:\Program Files\7-Zip\7z.exe" x %ARCHIVES%\libtorrent-1.0.6.7z -o%SOURCEROOT%\libtorrent
SET "PATH=%BUILDROOT%\Boost\bjam64\bin;%PATH%"
:: Disable asserts and invariant checks, we only need symbols; about invariant checks btw: http://kaba.hilvi.org/pastel/pastel/sys/ensure.htm
bjam -j8 -q --abbreviate-paths --toolset=msvc --prefix=%INST_DIR% boost=system boost-link=shared link=shared runtime-link=shared variant=debug debug-symbols=on asserts=off invariant-checks=off resolve-countries=on full-stats=on export-extra=on ipv6=on character-set=unicode geoip=static encryption=openssl windows-version=vista threading=multi address-model=64 host-os=windows target-os=windows embed-manifest=on architecture=x86 warnings=off warnings-as-errors=off "cflags=/Zi /FS /favor:blend" "linkflags=/NOLOGO /DEBUG /INCREMENTAL:NO" "include=%BUILDROOT%\OpenSSL\OpenSSL64d\include" "include=%BUILDROOT%\Boost\Boost64d\include" "library-path=%BUILDROOT%\OpenSSL\OpenSSL64d\lib" "library-path=%BUILDROOT%\Boost\Boost64d\lib" "define=BOOST_ALL_NO_LIB" install
IF ERRORLEVEL 1 GOTO FAIL
:: Copy debug symbols
FOR /R .\ %%X IN (torrent.pdb) DO (
	XCOPY /Y /Q /I %%X %INST_DIR%\lib\
)
:: Clean-up
IF EXIST %SOURCEROOT%\libtorrent\bin RD /S /Q %SOURCEROOT%\libtorrent\bin
GOTO CLEANUP
:END
CALL %SCRIPTROOT%\virgin.bat restore