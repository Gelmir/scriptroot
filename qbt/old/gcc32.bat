@ECHO OFF
:: Usage: 
:: set following env vars to control build flow
:: SET "NO_TAINT=1" - if defined experimental branch will bot be used
:: SET "TAG_RELEASE=3.0.8" - if defined build the defined release tag instead of master branch
:: SET "NO_PUBLIC=1" - do not make archive and do not build installer
GOTO BEGIN
:CLEANUP
CD %CWD%
SET LC_ALL=
SET PACKAGE=
SET INST_DIR=
SET QBT_VERSION=
SET NO_TAINT=
SET TAG_RELEASE=
SET BUILD_DATE=
SET BUILD_TIME=
SET GIT_TAG=
SET QB_STRING=
SET NO_PUBLIC=
IF EXIST %SOURCEROOT%\qbittorrent RD /S /Q %SOURCEROOT%\qbittorrent
GOTO END
:FAIL
ECHO Building failed, leaving source tree as is and dumping custom env vars
CD %CWD%
IF DEFINED LC_ALL ECHO LC_ALL = %LC_ALL%
IF DEFINED PACKAGE ECHO PACKAGE = %PACKAGE%
IF DEFINED INST_DIR ECHO INST_DIR = %INST_DIR%
IF DEFINED QBT_VERSION ECHO QBT_VERSION = %QBT_VERSION%
IF DEFINED QB_STRING ECHO QB_STRING = %QB_STRING%
IF DEFINED BUILD_DATE ECHO BUILD_DATE = %BUILD_DATE%
IF DEFINED BUILD_TIME ECHO BUILD_TIME = %BUILD_TIME%
IF DEFINED GIT_TAG ECHO GIT_TAG = %GIT_TAG%
IF DEFINED NO_TAINT (
  ECHO Build was not tainted
) ELSE (
  ECHO Build was tainted
)
IF DEFINED TAG_RELEASE (
  ECHO %TAG_RELEASE% release tag was used for building
) ELSE (
  ECHO Master branch was used for building
)
IF DEFINED NO_PUBLIC ECHO NO_PUBLIC = %NO_PUBLIC%
SET LC_ALL=
SET PACKAGE=
SET INST_DIR=
SET QBT_VERSION=
SET NO_TAINT=
SET TAG_RELEASE=
SET BUILD_DATE=
SET BUILD_TIME=
SET GIT_TAG=
SET QB_STRING=
SET NO_PUBLIC=
GOTO END
:: Control git branhes
:GIT_CMDS
:: Use release tag?
IF DEFINED TAG_RELEASE (
  git checkout --merge "release-%TAG_RELEASE%"
  IF ERRORLEVEL 1 GOTO FAIL
) ELSE (
  IF DEFINED NO_TAINT (
    git checkout --merge "master"
    IF ERRORLEVEL 1 GOTO FAIL
  ) ELSE (
    git checkout --merge "experimental"
    IF ERRORLEVEL 1 GOTO FAIL
  )
)
:: noop
ECHO.
FOR /F "delims=" %%X IN ('git describe --long') DO @SET GIT_TAG=%%X
XCOPY /E /Y /Q /I C:\Users\Dayman\Documents\GitHub\qBittorrent %SOURCEROOT%\qbittorrent\
GOTO CONTINUE
:BEGIN
:: Bitch please
:: Required for nested loops and ifs
REM Setlocal EnableDelayedExpansion
SET "INST_DIR=%BUILDROOT%\qBittorrent_G"
IF EXIST %INST_DIR% RD /S /Q %INST_DIR%
MD %INST_DIR%
CALL %SCRIPTROOT%\virgin.bat backup
SET CWD=%CD%
CALL "C:\Program Files (x86)\Microsoft Visual Studio 10.0\VC\bin\amd64\vcvars64.bat"
IF EXIST %SOURCEROOT%\qbittorrent RD /S /Q %SOURCEROOT%\qbittorrent
MD %SOURCEROOT%\qbittorrent
CD /D "C:\Users\Dayman\Documents\GitHub\qBittorrent"
:: Less manual work
IF DEFINED TAG_RELEASE (
  SET NO_TAINT=1
)
GOTO GIT_CMDS
:CONTINUE
CD /D %SOURCEROOT%\qbittorrent
:: Get qBt version for packaging
FOR /F "delims=" %%X IN ('findstr /R "^PROJECT_VERSION" .\version.pri ^| sed -e "s/^.* = \(.*\)/\1/"') DO @SET QBT_VERSION=%%X
"C:\Program Files\7-Zip\7z.exe" x T:\_compressed_sources\GeoIP.7z -o.\src\geoip\
:: Replace paths to libtorrent, boost, etc.
patch --binary -p1 -Nsfi %SCRIPTROOT%\qbt\patches\gcc32.patch
IF ERRORLEVEL 1 GOTO FAIL
patch --binary -p1 -Nsfi %SCRIPTROOT%\qbt\patches\strace_test.patch
IF ERRORLEVEL 1 GOTO FAIL
SET "PATH=%BUILDROOT%\Qt\Qt_G\bin;%PATH%"
CD .\src
lrelease ./src.pro
IF ERRORLEVEL 1 GOTO FAIL
:: Commenting till better times
REM FOR /R %SOURCEROOT%\qbittorrent\src\lang\ %%X IN (qbittorrent_*.qm) DO (
  REM :: DO NOT WRITE THIS IN ONE LINE
  REM FOR /F "delims= " %%Y IN ('ECHO %%X ^| sed -e "s/.*qbittorrent_\(.*\)\.qm/\1/"') DO (
    REM @SET TRANS_LANG=%%Y
  REM )
  REM REM ECHO !TRANS_LANG!
  REM REM ECHO %BUILDROOT%\Qt\Qt_G\translations\qt_!TRANS_LANG!.qm
  REM IF EXIST "%BUILDROOT%\Qt\Qt_G\translations\qt_!TRANS_LANG!.qm" (
    REM ECHO Merging language: !TRANS_LANG!
    REM lconvert --no-obsolete -i "%BUILDROOT%\Qt\Qt_G\translations\qt_!TRANS_LANG!.qm" -i "%%X" -o "%%X"
    REM IF ERRORLEVEL 1 GOTO FAIL
  REM )
REM )
REM SET TRANS_LANG=
CD ..\
MD build
CD build
qmake -config release -r ../qbittorrent.pro "CONFIG += strace_win warn_off rtti ltcg mmx sse sse2" "CONFIG -= 3dnow"
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
IF DEFINED NO_PUBLIC GOTO CLEANUP
:: Prepare packages for distribution
:: Archive
IF NOT DEFINED NO_TAINT (
  SET "QB_STRING=qBittorrent-experimental-%QBT_VERSION%-%GIT_TAG%"
) ELSE (
  SET "QB_STRING=qBittorrent-%QBT_VERSION%-%GIT_TAG%"
)
SET "PACKAGE=%PACKAGEDIR%\%QB_STRING%.7z"
IF EXIST %PACKAGE% DEL /Q %PACKAGE%
"C:\Program Files\7-Zip\7z.exe" a -t7z %PACKAGE% %INST_DIR% -mx9 -mmt=on -mf=on -mhc=on -ms=on -m0=LZMA2
IF ERRORLEVEL 1 GOTO FAIL
:: Optional sign with pgp
REM IF EXIST %PACKAGE%.sig DEL /Q %PACKAGE%.sig
REM SET LC_ALL=C
REM gpg --default-key 0x18792BAA -b %PACKAGE%
:: Installer (coming soon™); ok, it's here
ECHO Creating installer...
ECHO Installer log: %PACKAGEDIR%\%QB_STRING%-x64-setup.log
IF EXIST "%PACKAGEDIR%\%QB_STRING%-x64-setup.exe" DEL /Q "%PACKAGEDIR%\%QB_STRING%-x64-setup.exe"
"C:\Program Files (x86)\Inno Setup 5\ISCC.exe" "/dMyFilesRoot=%INST_DIR%" "/dPACKDIR=%PACKAGEDIR%" "/dMyAppVersion=%QBT_VERSION%" "/dMyIcon=%SOURCEROOT%\qbittorrent\src\qbittorrent.ico" "/f%QB_STRING%-x64-setup" "/o%PACKAGEDIR%" "%SCRIPTROOT%\qbt\qbt64.iss" > %PACKAGEDIR%\%QB_STRING%-x64-setup.log
IF ERRORLEVEL 1 GOTO FAIL
GOTO CLEANUP
:END
CALL %SCRIPTROOT%\virgin.bat restore