@ECHO OFF
GOTO BEGIN
:CLEANUP
SET QBT_ROOT=
SET QT5=
SET GCC=
GOTO END
:FAIL
ECHO Building failed, leaving source tree as is and dumping custom env vars
IF DEFINED QBT_ROOT ECHO QBT_ROOT = %QBT_ROOT%
IF DEFINED QT5 ECHO QT5 = %QT5%
IF DEFINED GCC ECHO GCC = %GCC%
SET QBT_ROOT=
SET QT5=
SET GCC=
GOTO END
:BEGIN
Setlocal EnableDelayedExpansion
SET "QBT_ROOT=C:\_\WORK\qBittorrent"
IF EXIST %QBT_ROOT%\qbittorrent.pro.user COPY /Y %QBT_ROOT%\qbittorrent.pro.user %TEMP%\qbittorrent.pro.user
IF EXIST %QBT_ROOT% RD /S /Q %QBT_ROOT%
IF EXIST %QBT_ROOT%\..\build-qbittorrent RD /S /Q %QBT_ROOT%\..\build-qbittorrent
MD %QBT_ROOT%
XCOPY /E /Y /Q /I C:\Users\Dayman\Documents\GitHub\qBittorrent %QBT_ROOT%\
IF EXIST %TEMP%\qbittorrent.pro.user COPY /Y %TEMP%\qbittorrent.pro.user %QBT_ROOT%\qbittorrent.pro.user
REM IF ERRORLEVEL 1 GOTO FAIL
"C:\Program Files\7-Zip\7z.exe" x %ARCHIVES%\GeoIP.7z -o%QBT_ROOT%\src\geoip\
IF ERRORLEVEL 1 GOTO FAIL
IF NOT DEFINED GCC GOTO MSVC
GOTO MINGW
:MSVC
IF DEFINED QT5 (
  patch -d %QBT_ROOT% -p1 -Nsfi %SCRIPTROOT%\qbt\patches\msvc64d_Qt5.patch
) ELSE (
  patch -d %QBT_ROOT% -p1 -Nsfi %SCRIPTROOT%\qbt\patches\msvc64d.patch
)
IF ERRORLEVEL 1 GOTO FAIL
GOTO CLEANUP
:MINGW
patch -d %QBT_ROOT% -p1 -Nsfi %SCRIPTROOT%\qbt\patches\gcc64.patch
IF ERRORLEVEL 1 GOTO FAIL
GOTO CLEANUP
:END
:: "CONFIG += strace_win warn_off msvc_mp rtti mmx sse sse2" "CONFIG -= 3dnow ltcg"
:: T:\_outdir\Qt\Qt64d\bin;T:\_outdir\OpenSSL\OpenSSL64d\bin;T:\_outdir\libtorrent\libtorrent64d\lib;T:\_outdir\Boost\Boost64d\lib;
:: T:\_outdir\Qt\Qt64_Qt5_qbt\bin;T:\_outdir\OpenSSL\OpenSSL64\bin;T:\_outdir\libtorrent\libtorrent64\lib;T:\_outdir\Boost\Boost64\lib;