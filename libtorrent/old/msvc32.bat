@ECHO OFF
IF NOT EXIST %BUILDROOT%\libtorrent MD %BUILDROOT%\libtorrent
SET "INST_DIR=%BUILDROOT%\libtorrent\libtorrent"
IF EXIST %INST_DIR% RD /S /Q %INST_DIR%
CALL %SCRIPTROOT%\virgin.bat backup
SET CWD=%CD%
CALL "C:\Program Files (x86)\Microsoft Visual Studio 11.0\VC\bin\vcvars32.bat"
IF EXIST %SOURCEROOT%\libtorrent RD /S /Q %SOURCEROOT%\libtorrent
MD %SOURCEROOT%\libtorrent
CD /D %SOURCEROOT%\libtorrent
"C:\Program Files\7-Zip\7z.exe" x T:\_compressed_sources\libtorrent-0.16.3.7z
patch --verbose -p1 -i %CWD%\patches\msvc.diff
patch --verbose -p1 -i %CWD%\patches\export_fix.diff
SET "PATH=%PATH%;%BUILDROOT%\Boost\bjam64\bin"
bjam -d+2 -j3 -q --toolset=msvc --prefix=%INST_DIR% boost=system boost-link=shared link=shared runtime-link=shared variant=release debug-symbols=off resolve-countries=on full-stats=on export-extra=off ipv6=on dht-support=on asserts=off character-set=unicode invariant-checks=off geoip=static encryption=openssl windows-version=xp threading=multi address-model=32 host-os=windows target-os=windows embed-manifest=on architecture=x86 inlining=full warnings=off warnings-as-errors=off optimization=speed "cflags=/O2 /MP /GL /arch:SSE" "linkflags=/NOLOGO /OPT:REF /OPT:ICF=5 /LTCG" "include=%BUILDROOT%\OpenSSL\OpenSSL\include" "include=%BUILDROOT%\Boost\Boost\include" "library-path=%BUILDROOT%\OpenSSL\OpenSSL\lib" "library-path=%BUILDROOT%\Boost\Boost\lib" install
CD ..\
RD /S /Q libtorrent
CD %CWD%
SET INST_DIR=
CALL %SCRIPTROOT%\virgin.bat restore