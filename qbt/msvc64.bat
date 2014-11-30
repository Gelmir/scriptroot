@ECHO OFF
:: Usage: 
:: set following env vars to control build flow
:: SET "NO_TAINT=1" - if defined experimental branch will bot be used
:: SET "TAG_RELEASE=3.0.8" - if defined build the defined release tag instead of master branch
:: SET "NO_PUBLIC=1" - do not make archive and do not build installer

:: TODO
:: Changelog generation
:: $ git diff -U0 release-3.0.11 release-3.1.0 Changelog | grep -vE "^\+{3,3} .\/Changelog$" | grep -E "^\+" | sed -e "s/^\+\(.*\)/\1/" > some/file.ext
GOTO BEGIN
:CLEANUP
CD /D %CWD%
SET LC_ALL=
SET PACKAGE=
SET INST_DIR=
SET QBT_VERSION=
SET NO_TAINT=
SET TAG_RELEASE=
SET GIT_TAG=
SET QB_STRING=
SET NO_PUBLIC=
SET LOG=
SET QT_VER=
IF DEFINED LT_MOVED (
	MOVE /Y %BUILDROOT%\libtorrent\libtorrent64 %BUILDROOT%\libtorrent\libtorrent64_0
    MOVE /Y %BUILDROOT%\libtorrent\libtorrent64_1 %BUILDROOT%\libtorrent\libtorrent64
	SET LT_MOVED=
)
IF EXIST %SOURCEROOT%\qbittorrent RD /S /Q %SOURCEROOT%\qbittorrent
GOTO END
:FAIL
ECHO Building failed, leaving source tree as is and dumping custom env vars
CD /D %CWD%
IF DEFINED LC_ALL ECHO LC_ALL = %LC_ALL%
IF DEFINED PACKAGE ECHO PACKAGE = %PACKAGE%
IF DEFINED INST_DIR ECHO INST_DIR = %INST_DIR%
IF DEFINED QBT_VERSION ECHO QBT_VERSION = %QBT_VERSION%
IF DEFINED QB_STRING ECHO QB_STRING = %QB_STRING%
IF DEFINED GIT_TAG ECHO GIT_TAG = %GIT_TAG%
IF DEFINED QT_VER ECHO QT_VER = %QT_VER%
IF DEFINED LT_MOVED ECHO LT_MOVED = %LT_MOVED%
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
IF DEFINED LOG ECHO LOG = %LOG%
SET LC_ALL=
SET PACKAGE=
SET INST_DIR=
SET QBT_VERSION=
SET NO_TAINT=
SET TAG_RELEASE=
SET GIT_TAG=
SET QB_STRING=
SET NO_PUBLIC=
SET LOG=
SET QT_VER=
IF DEFINED LT_MOVED (
	MOVE /Y %BUILDROOT%\libtorrent\libtorrent64 %BUILDROOT%\libtorrent\libtorrent64_0
    MOVE /Y %BUILDROOT%\libtorrent\libtorrent64_1 %BUILDROOT%\libtorrent\libtorrent64
	SET LT_MOVED=
)
GOTO END
:: Control git branhes
:GIT_CMDS
:: Use release tag?
IF DEFINED TAG_RELEASE (
  git checkout --merge "release-%TAG_RELEASE%"
  IF ERRORLEVEL 1 GOTO FAIL
  :: Move libtorrent
  MOVE /Y %BUILDROOT%\libtorrent\libtorrent64 %BUILDROOT%\libtorrent\libtorrent64_1
  MOVE /Y %BUILDROOT%\libtorrent\libtorrent64_0 %BUILDROOT%\libtorrent\libtorrent64
  SET LT_MOVED=1
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
IF NOT DEFINED TAG_RELEASE (
  SET "PATH=%BUILDROOT%\tx;%PATH%"
  :: Pull new translations from transifex
  tx pull -f -r qbittorrent.qbittorrent_master
)
:: noop
ECHO.
XCOPY /E /Y /Q /I C:\Users\Dayman\Documents\GitHub\qBittorrent %SOURCEROOT%\qbittorrent\
:: noop
ECHO.
IF NOT DEFINED TAG_RELEASE (
  git reset --hard
)
:: noop
ECHO.
GOTO CONTINUE
:BEGIN
:: Bitch please
:: Required for nested loops and ifs
Setlocal EnableDelayedExpansion
SET "INST_DIR=%BUILDROOT%\qBittorrent64"
IF EXIST %INST_DIR% RD /S /Q %INST_DIR%
MD %INST_DIR%
CALL %SCRIPTROOT%\virgin.bat backup
SET CWD=%CD%
CALL "C:\Program Files (x86)\Microsoft Visual Studio 11.0\VC\bin\x86_amd64\vcvarsx86_amd64.bat"
IF EXIST %SOURCEROOT%\qbittorrent RD /S /Q %SOURCEROOT%\qbittorrent
MD %SOURCEROOT%\qbittorrent
CD /D "C:\Users\Dayman\Documents\GitHub\qBittorrent"
:: Less manual work
IF DEFINED TAG_RELEASE (
  SET NO_TAINT=1
)
:: noop
ECHO.
GOTO GIT_CMDS
:CONTINUE
CD /D %SOURCEROOT%\qbittorrent
:: Get qBt version for packaging
IF DEFINED TAG_RELEASE (
  FOR /F "delims=" %%X IN ('findstr /R "^PROJECT_VERSION" .\version.pri ^| sed -e "s/^.* = \(.*\)/\1/"') DO @SET QBT_VERSION=%%X
) ELSE (
  FOR /F "delims=" %%X IN ('findstr /R "^VER_MAJOR" .\version.pri ^| sed -e "s/^.* = \(.*\)/\1/"') DO @SET QBT_VERSION=%%X
  FOR /F "delims=" %%X IN ('findstr /R "^VER_MINOR" .\version.pri ^| sed -e "s/^.* = \(.*\)/\1/"') DO @SET "QBT_VERSION=!QBT_VERSION!.%%X"
  FOR /F "delims=" %%X IN ('findstr /R "^VER_BUGFIX" .\version.pri ^| sed -e "s/^.* = \(.*\)/\1/"') DO @SET "QBT_VERSION=!QBT_VERSION!.%%X"
  FOR /F "delims=" %%X IN ('findstr /R "^VER_STATUS" .\version.pri ^| sed -e "s/^.* = \(.*\) #.*/\1/"') DO @SET "QBT_VERSION=!QBT_VERSION!%%X"
)
"C:\Program Files\7-Zip\7z.exe" x %ARCHIVES%\GeoIP.7z -o.\src\geoip\
IF NOT DEFINED NO_TAINT (
  SET QT_VER=5
) ELSE (
  SET QT_VER=4
)
:: noop
ECHO.
IF %QT_VER% == 5 (
  patch --binary -p1 -Nfi %SCRIPTROOT%\qbt\patches\msvc64_Qt5.patch
  IF ERRORLEVEL 1 GOTO FAIL
  SET "PATH=%BUILDROOT%\Qt\Qt5_x64_qbt\bin;%BUILDROOT%\jom;%BUILDROOT%\icu\icu64\bin64;%PATH%"
  :: Hack for Qt5 lupdate failures
  sed -i -e "s/^\(\ *QT += dbus\)/#\1/" ./unixconf.pri
) ELSE (
  patch --binary -p1 -Nfi %SCRIPTROOT%\qbt\patches\msvc64.patch
  IF ERRORLEVEL 1 GOTO FAIL
  SET "PATH=%BUILDROOT%\Qt\Qt4_x64_qbt\bin;%BUILDROOT%\jom;%PATH%"
)
lupdate -recursive -no-obsolete ./qbittorrent.pro
IF ERRORLEVEL 1 GOTO FAIL
MD build
CD build
IF NOT DEFINED LOG (
  qmake -config release -r ../qbittorrent.pro "CONFIG += strace_win warn_off rtti ltcg mmx sse sse2" "CONFIG -= 3dnow"
  IF ERRORLEVEL 1 GOTO FAIL
) ELSE (
  qmake -config release -r ../qbittorrent.pro "CONFIG += strace_win warn_off rtti ltcg mmx sse sse2" "CONFIG -= 3dnow" "DEFINES += TORRENT_DISK_STATS TORRENT_LOGGING"
  IF ERRORLEVEL 1 GOTO FAIL
)
jom -j4
IF ERRORLEVEL 1 GOTO FAIL
COPY /Y .\src\release\qbittorrent.exe %INST_DIR%\
IF EXIST .\src\release\qbittorrent.pdb COPY /Y .\src\release\qbittorrent.pdb %INST_DIR%\
IF %QT_VER% == 5 (
  FOR %%X IN (Qt5Core.dll Qt5Gui.dll Qt5Network.dll Qt5Widgets.dll Qt5Xml.dll) DO (
    COPY /Y %BUILDROOT%\Qt\Qt5_x64_qbt\bin\%%X %INST_DIR%\
  )
  :: Only qico4.dll is required
  XCOPY /Y /Q /I %BUILDROOT%\Qt\Qt5_x64_qbt\plugins\imageformats\qico.dll %INST_DIR%\plugins\imageformats\
  :: Not sure if needed
  XCOPY /Y /Q /I /E %BUILDROOT%\Qt\Qt5_x64_qbt\plugins\platforms %INST_DIR%\plugins\platforms
  :: Use newer Qt translations if possible
  :: Now I HAVE to use perl for non-greedy regex :(
  FOR /F "usebackq" %%X IN (`DIR /B "%SOURCEROOT%\qbittorrent\src\qt-translations\" ^| perl -pe "s/^.*?_(.*)/\1/"`) DO (
    IF EXIST "%BUILDROOT%\Qt\Qt5_x64_qbt\translations\qt_%%X" (
      COPY /Y "%BUILDROOT%\Qt\Qt5_x64_qbt\translations\qt_%%X" "%SOURCEROOT%\qbittorrent\src\qt-translations\"
    )
    IF EXIST "%BUILDROOT%\Qt\Qt5_x64_qbt\translations\qtbase_%%X" (
      COPY /Y "%BUILDROOT%\Qt\Qt5_x64_qbt\translations\qtbase_%%X" "%SOURCEROOT%\qbittorrent\src\qt-translations\"
    )
  )
  XCOPY /Y /Q /I %SOURCEROOT%\qbittorrent\src\qt-translations\qt_* %INST_DIR%\translations\
  XCOPY /Y /Q /I %SOURCEROOT%\qbittorrent\src\qt-translations\qtbase_* %INST_DIR%\translations\
) ELSE (
  FOR %%X IN (QtCore4.dll QtGui4.dll QtNetwork4.dll QtXml4.dll) DO (
    COPY /Y %BUILDROOT%\Qt\Qt4_x64_qbt\bin\%%X %INST_DIR%\
  )
  :: Only qico4.dll is required
  XCOPY /Y /Q /I %BUILDROOT%\Qt\Qt4_x64_qbt\plugins\imageformats\qico4.dll %INST_DIR%\plugins\imageformats\
  :: Use newer Qt translations if possible
  FOR /F "usebackq" %%X IN (`DIR /B "%SOURCEROOT%\qbittorrent\src\qt-translations\"`) DO (
    IF EXIST "%BUILDROOT%\Qt\Qt4_x64_qbt\translations\%%X" (
      COPY /Y "%BUILDROOT%\Qt\Qt4_x64_qbt\translations\%%X" "%SOURCEROOT%\qbittorrent\src\qt-translations\"
    )
  )
  XCOPY /Y /Q /I %SOURCEROOT%\qbittorrent\src\qt-translations\qt_* %INST_DIR%\translations\
)
echo [Paths] > %INST_DIR%\qt.conf
echo Translations = ./translations >> %INST_DIR%\qt.conf
echo Plugins = ./plugins >> %INST_DIR%\qt.conf
XCOPY /Y /Q %BUILDROOT%\OpenSSL\OpenSSL64\bin\*.dll %INST_DIR%\
COPY /Y %BUILDROOT%\libtorrent\libtorrent64\lib\torrent.dll %INST_DIR%\
XCOPY /Y /Q %BUILDROOT%\Boost\Boost64\lib\*.dll %INST_DIR%\
:: Copy VC++ 2012 x64 Redist DLLs
COPY /Y "%VCINSTALLDIR%\redist\x64\Microsoft.VC110.CRT\msvcp110.dll" %INST_DIR%\
COPY /Y "%VCINSTALLDIR%\redist\x64\Microsoft.VC110.CRT\msvcr110.dll" %INST_DIR%\
COPY /Y "C:\Program Files (x86)\Windows Kits\8.1\Debuggers\x86\dbghelp.dll" %INST_DIR%\
:: Copy License
COPY /Y %SOURCEROOT%\qbittorrent\COPYING %INST_DIR%\LICENSE.txt
unix2dos -ascii %INST_DIR%\LICENSE.txt
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