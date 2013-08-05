@ECHO OFF
GOTO BEGIN
:CLEANUP
CD %CWD%
SET INST_DIR=
SET RC=
REM IF EXIST %SOURCEROOT%\libtorrent RD /S /Q %SOURCEROOT%\libtorrent
GOTO END
:FAIL
ECHO Building failed, leaving source tree as is and dumping custom env vars
CD %CWD%
IF DEFINED INST_DIR ECHO INST_DIR = %INST_DIR%
IF DEFINED RC ECHO RC = %RC%
SET INST_DIR=
SET RC=
GOTO END
:BEGIN
IF NOT EXIST %BUILDROOT%\libtorrent MD %BUILDROOT%\libtorrent
SET "INST_DIR=%BUILDROOT%\libtorrent\libtorrent64d"
IF EXIST %INST_DIR% RD /S /Q %INST_DIR%
CALL %SCRIPTROOT%\virgin.bat backup
SET CWD=%CD%
CALL "C:\Program Files (x86)\Microsoft Visual Studio 10.0\VC\bin\amd64\vcvars64.bat"
IF EXIST %SOURCEROOT%\libtorrent RD /S /Q %SOURCEROOT%\libtorrent
MD %SOURCEROOT%\libtorrent
CD %SOURCEROOT%\libtorrent
IF NOT DEFINED RC (
  "C:\Program Files\7-Zip\7z.exe" x %ARCHIVES%\libtorrent-0.16.10.7z -o%SOURCEROOT%\libtorrent
  patch --binary -p1 -Nfi %SCRIPTROOT%\libtorrent\patches\export_fix.patch
  IF ERRORLEVEL 1 GOTO FAIL
  patch --binary -p3 -Nfi %SCRIPTROOT%\libtorrent\patches\boost_1_54_fix.patch
  IF ERRORLEVEL 1 GOTO FAIL
  patch --binary -p3 -Nfi %SCRIPTROOT%\libtorrent\patches\disk-stats.patch
  IF ERRORLEVEL 1 GOTO FAIL
) ELSE (
  XCOPY /Y /E /Q /I C:\Users\Dayman\Documents\vcs\libtorrent %SOURCEROOT%\libtorrent\
  COPY /Y %SCRIPTROOT%\libtorrent\patches\export_fix.patch %SOURCEROOT%\libtorrent\
  unix2dos %SOURCEROOT%\libtorrent\export_fix.patch
  IF ERRORLEVEL 1 GOTO FAIL
  patch -p1 -Nfi %SOURCEROOT%\libtorrent\export_fix.patch
  IF ERRORLEVEL 1 GOTO FAIL
)
SET "PATH=%BUILDROOT%\Boost\bjam64\bin;%PATH%"
:: Disable asserts and invariant checks, we only need symbols; about invariant checks btw: http://kaba.hilvi.org/pastel/pastel/sys/ensure.htm
bjam -j4 -q --toolset=msvc --prefix=%INST_DIR% boost=system boost-link=shared link=shared runtime-link=shared variant=debug debug-symbols=on asserts=off invariant-checks=off resolve-countries=on full-stats=on export-extra=off ipv6=on dht-support=on character-set=unicode geoip=static encryption=openssl windows-version=vista threading=multi address-model=64 host-os=windows target-os=windows embed-manifest=on architecture=x86 warnings=off warnings-as-errors=off "cflags=/Zi /favor:blend" "linkflags=/NOLOGO /DEBUG /INCREMENTAL:NO" "include=%BUILDROOT%\OpenSSL\OpenSSL64d\include" "include=%BUILDROOT%\Boost\Boost64d\include" "library-path=%BUILDROOT%\OpenSSL\OpenSSL64d\lib" "library-path=%BUILDROOT%\Boost\Boost64d\lib" "define=BOOST_ALL_NO_LIB" install
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