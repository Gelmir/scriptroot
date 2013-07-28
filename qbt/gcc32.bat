@ECHO OFF
:: Usage: 
:: set following env vars to control build flow
:: SET "NO_TAINT=1" - if defined experimental branch will bot be used
:: SET "TAG_RELEASE=3.0.8" - if defined build the defined release tag instead of master branch
:: SET "NO_PUBLIC=1" - do not make archive and do not build installer
GOTO BEGIN
:CLEANUP
CD /D %CWD%
SET INST_DIR=
IF EXIST %SOURCEROOT%\qbittorrent RD /S /Q %SOURCEROOT%\qbittorrent
GOTO END
:FAIL
ECHO Building failed, leaving source tree as is and dumping custom env vars
CD /D %CWD%
IF DEFINED INST_DIR ECHO INST_DIR = %INST_DIR%
SET INST_DIR=
GOTO END
:BEGIN
:: Bitch please
:: Required for nested loops and ifs
REM Setlocal EnableDelayedExpansion
SET "INST_DIR=%BUILDROOT%\qBittorrent_G"
IF EXIST %INST_DIR% RD /S /Q %INST_DIR%
MD %INST_DIR%
CALL %SCRIPTROOT%\virgin.bat backup
SET CWD=%CD%
IF EXIST %SOURCEROOT%\qbittorrent RD /S /Q %SOURCEROOT%\qbittorrent
MD %SOURCEROOT%\qbittorrent
XCOPY /E /Y /Q /I C:\Users\Dayman\Documents\GitHub\qBittorrent %SOURCEROOT%\qbittorrent\
CD /D %SOURCEROOT%\qbittorrent
"C:\Program Files\7-Zip\7z.exe" x T:\_compressed_sources\GeoIP.7z -o.\src\geoip\
:: Replace paths to libtorrent, boost, etc.
patch --binary -p1 -Nfi %SCRIPTROOT%\qbt\patches\gcc32.patch
IF ERRORLEVEL 1 GOTO FAIL
SET "PATH=%BUILDROOT%\Qt\Qt_G\bin;%PATH%"
CD .\src
REM lupdate -no-obsolete ./src.pro
IF ERRORLEVEL 1 GOTO FAIL
CD ..\
MD build
CD build
qmake -config release -r ../qbittorrent.pro "CONFIG += warn_off rtti ltcg mmx sse sse2" "CONFIG -= 3dnow"
IF ERRORLEVEL 1 GOTO FAIL
mingw32-make -j4
IF ERRORLEVEL 1 GOTO FAIL
COPY /Y .\src\release\qbittorrent.exe %INST_DIR%\
FOR %%X IN (QtCore4.dll QtGui4.dll QtNetwork4.dll QtXml4.dll) DO (
    COPY /Y %BUILDROOT%\Qt\Qt_G\bin\%%X %INST_DIR%\
)
:: Only qico4.dll is required
XCOPY /Y /Q /I %BUILDROOT%\Qt\Qt_G\plugins\imageformats\qico4.dll %INST_DIR%\plugins\imageformats\
XCOPY /Y /Q /I %BUILDROOT%\Qt\Qt_G\translations\qt_* %INST_DIR%\translations\
DEL /Q %INST_DIR%\translations\qt_help*
echo [Paths] > %INST_DIR%\qt.conf
echo Translations = ./translations >> %INST_DIR%\qt.conf
echo Plugins = ./plugins >> %INST_DIR%\qt.conf
XCOPY /Y /Q %BUILDROOT%\OpenSSL\OpenSSL_G\bin\*.dll %INST_DIR%\
COPY /Y %BUILDROOT%\libtorrent\libtorrent_G\lib\libtorrent.dll %INST_DIR%\
XCOPY /Y /Q %BUILDROOT%\Boost\Boost_G\lib\*.dll %INST_DIR%\
:: Copy mingw runtime
XCOPY /Y /Q T:\MinGW\bin\libgcc_s_sjlj-1.dll %INST_DIR%\
XCOPY /Y /Q T:\MinGW\bin\libstdc++-6.dll %INST_DIR%\
XCOPY /Y /Q T:\MinGW\bin\libwinpthread-1.dll %INST_DIR%\
XCOPY /Y /Q T:\MinGW\bin\libssp-0.dll %INST_DIR%\
:: Copy License
COPY /Y %SOURCEROOT%\qbittorrent\COPYING %INST_DIR%\LICENSE.txt
:: Remove Unprintable ASCII 0x0C from License
sed -b -e "s/^\x0C\(.*\)/\1/" < %INST_DIR%\LICENSE.txt > %INST_DIR%\LICENSE.txt.%SEDEXT%
MOVE /Y %INST_DIR%\LICENSE.txt.%SEDEXT% %INST_DIR%\LICENSE.txt
GOTO CLEANUP
:END
CALL %SCRIPTROOT%\virgin.bat restore