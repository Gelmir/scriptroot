@ECHO OFF
GOTO BEGIN
:CLEANUP
SET QBT_ROOT=
GOTO END
:FAIL
ECHO Building failed, leaving source tree as is and dumping custom env vars
IF DEFINED QBT_ROOT ECHO QBT_ROOT = %QBT_ROOT%
SET QBT_ROOT=
GOTO END
:BEGIN
SET "QBT_ROOT=T:\WORK\qBittorrent"
IF EXIST %QBT_ROOT%\qbittorrent.pro.user COPY /Y %QBT_ROOT%\qbittorrent.pro.user %TEMP%\qbittorrent.pro.user
IF EXIST %QBT_ROOT% RD /S /Q %QBT_ROOT%
IF EXIST %QBT_ROOT%\..\build-qbittorrent RD /S /Q %QBT_ROOT%\..\build-qbittorrent
MD %QBT_ROOT%
XCOPY /E /Y /Q /I C:\Users\Dayman\Documents\GitHub\qBittorrent %QBT_ROOT%\
IF EXIST %TEMP%\qbittorrent.pro.user COPY /Y %TEMP%\qbittorrent.pro.user %QBT_ROOT%\qbittorrent.pro.user
IF ERRORLEVEL 1 GOTO FAIL
"C:\Program Files\7-Zip\7z.exe" x T:\_compressed_sources\GeoIP.7z -o%QBT_ROOT%\src\geoip\
IF ERRORLEVEL 1 GOTO FAIL
patch --binary -d %QBT_ROOT% -p1 -Nsfi %SCRIPTROOT%\qbt\patches\msvc64d.patch
IF ERRORLEVEL 1 GOTO FAIL
GOTO CLEANUP
:END
:: "CONFIG += strace_win warn_off msvc_mp rtti mmx sse sse2" "CONFIG -= 3dnow ltcg"
:: T:\_outdir\Qt\Qt64d\bin;T:\_outdir\OpenSSL\OpenSSL64d\bin;T:\_outdir\libtorrent\libtorrent64d\lib;T:\_outdir\Boost\Boost64d\lib;
:: T:\_outdir\Qt\Qt64_Qt5_qbt\bin;T:\_outdir\OpenSSL\OpenSSL64\bin;T:\_outdir\libtorrent\libtorrent64\lib;T:\_outdir\Boost\Boost64\lib;