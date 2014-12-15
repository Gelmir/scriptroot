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
SET "INST_DIR=%BUILDROOT%\libtorrent\libtorrent64_G"
IF EXIST %INST_DIR% RD /S /Q %INST_DIR%
CALL %SCRIPTROOT%\virgin.bat backup
SET CWD=%CD%
IF EXIST %SOURCEROOT%\libtorrent RD /S /Q %SOURCEROOT%\libtorrent
MD %SOURCEROOT%\libtorrent
"C:\Program Files\7-Zip\7z.exe" x %ARCHIVES%\libtorrent-1.0.3.7z -o%SOURCEROOT%\libtorrent
CD %SOURCEROOT%\libtorrent
REM patch --binary -p3 -Nfi %SCRIPTROOT%\libtorrent\patches\gcc.patch
IF ERRORLEVEL 1 GOTO FAIL
sed -i -e "s/^\(.*<name>\)ssleay32\(.*\)/\1libssl\2/" -e "s/^\(.*<name>\)libeay32\(.*\)/\1libcrypto\2/" %SOURCEROOT%\libtorrent\Jamfile
SET "PATH=%BUILDROOT%\Boost\bjam64\bin;C:\_\MinGW\bin;%PATH%"
SET LC_ALL=C
:: Static build is broken, looks like cmd line args overflow (symbols get swallowed in the middle; ref: https://code.google.com/p/libtorrent/issues/detail?id=75&can=1&q=mingw UNFIXED)
bjam -j4 -q --abbreviate-paths --toolset=gcc --prefix=%INST_DIR% boost=system boost-link=shared link=shared runtime-link=shared variant=release debug-symbols=off export-extra=on resolve-countries=on full-stats=on ipv6=on asserts=off character-set=unicode invariant-checks=off geoip=static encryption=openssl windows-version=vista threading=multi address-model=64 architecture=x86 host-os=windows target-os=windows warnings=off warnings-as-errors=off inlining=on optimization=off "cflags=-O2 -mtune=generic -mmmx -msse -msse2 -fomit-frame-pointer -fpredictive-commoning -pipe -finline-small-functions -fstack-protector-all" "linkflags=-fstack-protector-all -Wl,-O1 -Wl,--as-needed -Wl,-s -shared-libgcc -Wl,--nxcompat -Wl,--dynamicbase" "include=%BUILDROOT%\Boost\Boost64_G\include" "include=%BUILDROOT%\OpenSSL\OpenSSL64_G\include" "library-path=%BUILDROOT%\OpenSSL\OpenSSL64_G\lib" "library-path=%BUILDROOT%\Boost\Boost64_G\lib" "define=BOOST_ALL_NO_LIB" install
IF ERRORLEVEL 1 GOTO FAIL
GOTO CLEANUP
:END
CALL %SCRIPTROOT%\virgin.bat restore