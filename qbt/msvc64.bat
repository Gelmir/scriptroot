@ECHO OFF
:: Usage: 
:: set following env vars to control build flow
:: SET "NO_TAINT=1" - if defined experimental branch will bot be used
:: SET "TAG_RELEASE=release-3.0.8" - if defined build the defined release tag instead of master branch
:: SET "NO_PUBLIC=1" - do not make archive and do not build installer
:: SET "SIDE_BUILD=1" - uses a different path for the build

:: TODO
:: Changelog generation
:: $ git diff -U0 release-3.0.11 release-3.1.0 Changelog | grep -vE "^\+{3,3} .\/Changelog$" | grep -E "^\+" | sed -e "s/^\+\(.*\)/\1/" > some/file.ext
GOTO BEGIN
:CLEANUP
CD /D %CWD%
IF %SIDE_BUILD% == 1 (
	IF EXIST %INST_DIR% RD /S /Q %INST_DIR%
)
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
SET SIDE_BUILD=
IF %USE_LT11% == 0 (
	MOVE /Y %BUILDROOT%\libtorrent\libtorrent64 %BUILDROOT%\libtorrent\libtorrent64_0
    MOVE /Y %BUILDROOT%\libtorrent\libtorrent64_1 %BUILDROOT%\libtorrent\libtorrent64
)
SET USE_LT11=
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
IF DEFINED SIDE_BUILD ECHO SIDE_BUILD = %SIDE_BUILD%
IF DEFINED USE_LT11 ECHO USE_LT11 = %USE_LT11%
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
SET SIDE_BUILD=
IF %USE_LT11% == 0 (
	MOVE /Y %BUILDROOT%\libtorrent\libtorrent64 %BUILDROOT%\libtorrent\libtorrent64_0
    MOVE /Y %BUILDROOT%\libtorrent\libtorrent64_1 %BUILDROOT%\libtorrent\libtorrent64
)
SET USE_LT11=
GOTO END
:: Control git branhes
:GIT_CMDS
:: Use release tag?
IF DEFINED TAG_RELEASE (
  git checkout --merge %TAG_RELEASE%
  IF ERRORLEVEL 1 GOTO FAIL
  ECHO.
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
XCOPY /E /Y /Q /I D:\Users\Nick\Documents\GitHub\qBittorrent %SOURCEROOT%\qbittorrent\
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
IF NOT DEFINED SIDE_BUILD (
	SET SIDE_BUILD=0
)
IF %SIDE_BUILD% == 1 (
	SET "INST_DIR=%TEMP%\qBittorrent64"
) ELSE (
	SET "INST_DIR=%BUILDROOT%\qBittorrent64"
)
IF EXIST %INST_DIR% RD /S /Q %INST_DIR%
MD %INST_DIR%
CALL %SCRIPTROOT%\virgin.bat backup
SET CWD=%CD%
CALL "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build\vcvars64.bat"
IF EXIST %SOURCEROOT%\qbittorrent RD /S /Q %SOURCEROOT%\qbittorrent
MD %SOURCEROOT%\qbittorrent
CD /D "D:\Users\Nick\Documents\GitHub\qBittorrent"
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
FOR /F "delims=" %%X IN ('findstr /R "^VER_MAJOR" .\version.pri ^| sed -e "s/^.* = \(.*\)/\1/"') DO @SET QBT_VERSION=%%X
FOR /F "delims=" %%X IN ('findstr /R "^VER_MINOR" .\version.pri ^| sed -e "s/^.* = \(.*\)/\1/"') DO @SET "QBT_VERSION=!QBT_VERSION!.%%X"
FOR /F "delims=" %%X IN ('findstr /R "^VER_BUGFIX" .\version.pri ^| sed -e "s/^.* = \(.*\)/\1/"') DO @SET "QBT_VERSION=!QBT_VERSION!.%%X"
IF NOT DEFINED TAG_RELEASE (
  FOR /F "delims=" %%X IN ('findstr /R "^VER_STATUS" .\version.pri ^| sed -e "s/^.* = \(.*\) #.*/\1/"') DO @SET "QBT_VERSION=!QBT_VERSION!%%X"
)
"C:\Program Files\7-Zip\7z.exe" -y x %ARCHIVES%\GeoIP.7z -o.\src\gui\geoip\
IF ERRORLEVEL 1 GOTO FAIL
IF NOT DEFINED USE_LT11 (
    SET USE_LT11=0
)
:: NOOP
ECHO.
IF %USE_LT11% == 1 (
    SET "LT_STRING=libtorrent1.1"
) ELSE (
    SET "LT_STRING=libtorrent1.0"
)
:: NOOP
ECHO.
IF %USE_LT11% == 1 (
    patch -p1 -Nfi %SCRIPTROOT%\qbt\patches\msvc64.patch
    IF ERRORLEVEL 1 GOTO FAIL
) ELSE (
    patch -p1 -Nfi %SCRIPTROOT%\qbt\patches\msvc64_lt_1.0.x.patch
    IF ERRORLEVEL 1 GOTO FAIL
    :: Move libtorrent
    MOVE /Y %BUILDROOT%\libtorrent\libtorrent64 %BUILDROOT%\libtorrent\libtorrent64_1
    MOVE /Y %BUILDROOT%\libtorrent\libtorrent64_0 %BUILDROOT%\libtorrent\libtorrent64
)
:: NOOP
ECHO.
SET "PATH=%BUILDROOT%\Qt\Qt5_x64_qbt\bin;%BUILDROOT%\jom;%PATH%"
SET "QMAKESPEC=%BUILDROOT%\Qt\Qt5_x64_qbt\mkspecs\win32-msvc"
COPY /Y %BUILDROOT%\Qt\Qt5_x64_qbt\bin\lupdate.exe %SOURCEROOT%\qbittorrent
%SOURCEROOT%\qbittorrent\lupdate.exe -recursive -no-obsolete ./qbittorrent.pro
IF ERRORLEVEL 1 GOTO FAIL
DEL /Q %SOURCEROOT%\qbittorrent\lupdate.exe
:: Revert icon commit from 3.3.x branch 
git apply -R %SCRIPTROOT%\qbt\patches\9999-Edit-speed-limits-and-upload-ratio-icons.patch
IF ERRORLEVEL 1 GOTO FAIL
:: Add New icons
git apply %SCRIPTROOT%\qbt\patches\0001-Added-stylized-icons-for-the-main-actions-bar.patch
IF ERRORLEVEL 1 GOTO FAIL
git apply %SCRIPTROOT%\qbt\patches\0002-60-of-the-svg-s-in-the-oxigen-folder-converted.patch
IF ERRORLEVEL 1 GOTO FAIL
git apply %SCRIPTROOT%\qbt\patches\0003-converted-all-oxygen-icons-to-svg-files-added-grunt-.patch
IF ERRORLEVEL 1 GOTO FAIL
git apply %SCRIPTROOT%\qbt\patches\0004-Added-the-last-of-the-skin-icons-svg.patch
IF ERRORLEVEL 1 GOTO FAIL
git apply %SCRIPTROOT%\qbt\patches\0005-Added-png-converted-files-for-skin-icons.patch
IF ERRORLEVEL 1 GOTO FAIL
git apply %SCRIPTROOT%\qbt\patches\0006-Delete-arrow-right.svg.patch
IF ERRORLEVEL 1 GOTO FAIL
git apply %SCRIPTROOT%\qbt\patches\0007-Delete-collapse-expand.svg.patch
IF ERRORLEVEL 1 GOTO FAIL
git apply %SCRIPTROOT%\qbt\patches\0008-resized-icons-to-32px-by-32px.patch
IF ERRORLEVEL 1 GOTO FAIL
git apply %SCRIPTROOT%\qbt\patches\0009-Update-icon-size-of-pngs-to-256px-make-pause-icon-wi.patch
IF ERRORLEVEL 1 GOTO FAIL
:: Fix Build failure
git apply %SCRIPTROOT%\qbt\patches\0001-Fix-LogMsg-not-found.patch
IF ERRORLEVEL 1 GOTO FAIL
SET "QMAKESPEC="
MD build
CD build
IF NOT DEFINED LOG (
  qmake -config release -r ../qbittorrent.pro "CONFIG += strace_win warn_off rtti ltcg mmx sse sse2" "CONFIG -= 3dnow" "INCLUDEPATH += D:/Users/Nick/Programs/Boost/Boost64/include" "INCLUDEPATH += D:/Users/Nick/Programs/libtorrent/libtorrent64/include" "INCLUDEPATH += D:/Users/Nick/Programs/Zlib/Zlib64/include" "INCLUDEPATH += D:/Users/Nick/Programs/OpenSSL/OpenSSL64/include" "LIBS += -LD:/Users/Nick/Programs/Boost/Boost64/lib" "LIBS += -LD:/Users/Nick/Programs/libtorrent/libtorrent64/lib" "LIBS += -LD:/Users/Nick/Programs/Zlib/Zlib64/lib" "LIBS += -LD:/Users/Nick/Programs/OpenSSL/OpenSSL64/lib" "LIBS += ole32.lib"
  IF ERRORLEVEL 1 GOTO FAIL
) ELSE (
  qmake -config release -r ../qbittorrent.pro "CONFIG += strace_win warn_off rtti ltcg mmx sse sse2" "CONFIG -= 3dnow" "DEFINES += TORRENT_DISK_STATS TORRENT_LOGGING" "INCLUDEPATH += D:/Users/Nick/Programs/Boost/Boost64/include" "INCLUDEPATH += D:/Users/Nick/Programs/libtorrent/libtorrent64/include" "INCLUDEPATH += D:/Users/Nick/Programs/Zlib/Zlib64/include" "INCLUDEPATH += D:/Users/Nick/Programs/OpenSSL/OpenSSL64/include" "LIBS += -LD:/Users/Nick/Programs/Boost/Boost64/lib" "LIBS += -LD:/Users/Nick/Programs/libtorrent/libtorrent64/lib" "LIBS += -LD:/Users/Nick/Programs/Zlib/Zlib64/lib" "LIBS += -LD:/Users/Nick/Programs/OpenSSL/OpenSSL64/lib" "LIBS += ole32.lib"
  IF ERRORLEVEL 1 GOTO FAIL
)
jom -j8
IF ERRORLEVEL 1 GOTO FAIL
COPY /Y .\src\release\qbittorrent.exe %INST_DIR%\
IF EXIST .\src\release\qbittorrent.pdb COPY /Y .\src\release\qbittorrent.pdb %INST_DIR%\

FOR %%X IN (Qt5Core.dll Qt5Gui.dll Qt5Network.dll Qt5Widgets.dll Qt5Xml.dll) DO (
  COPY /Y %BUILDROOT%\Qt\Qt5_x64_qbt\bin\%%X %INST_DIR%\
)
:: Only qico4.dll is required
XCOPY /Y /Q /I %BUILDROOT%\Qt\Qt5_x64_qbt\plugins\imageformats\qico.dll %INST_DIR%\plugins\imageformats\
:: Not sure if needed
XCOPY /Y /Q /I /E %BUILDROOT%\Qt\Qt5_x64_qbt\plugins\platforms %INST_DIR%\plugins\platforms
:: Use newer Qt translations if possible
:: Now I HAVE to use perl for non-greedy regex :(
FOR /F "usebackq" %%X IN (`DIR /B "%SOURCEROOT%\qbittorrent\dist\qt-translations\" ^| perl -pe "s/^.*?_(.*)/\1/"`) DO (
  IF EXIST "%BUILDROOT%\Qt\Qt5_x64_qbt\translations\qt_%%X" (
    COPY /Y "%BUILDROOT%\Qt\Qt5_x64_qbt\translations\qt_%%X" "%SOURCEROOT%\qbittorrent\dist\qt-translations\"
  )
  IF EXIST "%BUILDROOT%\Qt\Qt5_x64_qbt\translations\qtbase_%%X" (
    COPY /Y "%BUILDROOT%\Qt\Qt5_x64_qbt\translations\qtbase_%%X" "%SOURCEROOT%\qbittorrent\dist\qt-translations\"
  )
)
XCOPY /Y /Q /I %SOURCEROOT%\qbittorrent\dist\qt-translations\qt_* %INST_DIR%\translations\
XCOPY /Y /Q /I %SOURCEROOT%\qbittorrent\dist\qt-translations\qtbase_* %INST_DIR%\translations\

echo [Paths] > %INST_DIR%\qt.conf
echo Translations = ./translations >> %INST_DIR%\qt.conf
echo Plugins = ./plugins >> %INST_DIR%\qt.conf
XCOPY /Y /Q %BUILDROOT%\OpenSSL\OpenSSL64\bin\*.dll %INST_DIR%\
COPY /Y %BUILDROOT%\libtorrent\libtorrent64\lib\torrent.dll %INST_DIR%\
COPY /Y %BUILDROOT%\Boost\Boost64\lib\boost_system.dll %INST_DIR%\
:: LT 1.1.0 and higher needs chrono + random
COPY /Y %BUILDROOT%\Boost\Boost64\lib\boost_chrono.dll %INST_DIR%\
COPY /Y %BUILDROOT%\Boost\Boost64\lib\boost_random.dll %INST_DIR%\
:: Copy VC++ 2012 x64 Redist DLLs
COPY /Y "%VCINSTALLDIR%\Redist\MSVC\14.10.25008\x64\Microsoft.VC150.CRT\msvcp140.dll" %INST_DIR%\
COPY /Y "%VCINSTALLDIR%\Redist\MSVC\14.10.25008\x64\Microsoft.VC150.CRT\concrt140.dll" %INST_DIR%\
COPY /Y "%VCINSTALLDIR%\Redist\MSVC\14.10.25008\x64\Microsoft.VC150.CRT\vccorlib140.dll" %INST_DIR%\
COPY /Y "%VCINSTALLDIR%\Redist\MSVC\14.10.25008\x64\Microsoft.VC150.CRT\vcruntime140.dll" %INST_DIR%\
COPY /Y "C:\Program Files (x86)\Windows Kits\8.1\Debuggers\x64\dbghelp.dll" %INST_DIR%\
:: Copy License
COPY /Y %SOURCEROOT%\qbittorrent\COPYING %INST_DIR%\LICENSE.txt
unix2dos -ascii %INST_DIR%\LICENSE.txt
IF DEFINED NO_PUBLIC GOTO CLEANUP
:: Prepare packages for distribution
:: Archive
IF NOT DEFINED NO_TAINT (
  SET "QB_STRING=qBittorrent-experimental-%QBT_VERSION%-%GIT_TAG%-%LT_STRING%
) ELSE (
  SET "QB_STRING=qBittorrent-%QBT_VERSION%-%GIT_TAG%-%LT_STRING%
)
SET "PACKAGE=%PACKAGEDIR%\%QB_STRING%.7z"
IF EXIST %PACKAGE% DEL /Q %PACKAGE%
"C:\Program Files\7-Zip\7z.exe" a -t7z %PACKAGE% %INST_DIR% -mx9 -mmt=on -mf=on -mhc=on -ms=on -m0=LZMA2
IF ERRORLEVEL 1 GOTO FAIL
:: Installer (coming soon™); ok, it's here
ECHO Creating installer...
ECHO Installer log: %PACKAGEDIR%\%QB_STRING%-x64-setup.log
IF EXIST "%PACKAGEDIR%\%QB_STRING%-x64-setup.exe" DEL /Q "%PACKAGEDIR%\%QB_STRING%-x64-setup.exe"
"C:\Program Files (x86)\Inno Setup 5\ISCC.exe" "/dMyFilesRoot=%INST_DIR%" "/dPACKDIR=%PACKAGEDIR%" "/dMyAppVersion=%QBT_VERSION%" "/dMyIcon=%SOURCEROOT%\qbittorrent\src\qbittorrent.ico" "/f%QB_STRING%-x64-setup" "/o%PACKAGEDIR%" "%SCRIPTROOT%\qbt\qbt64.iss" > %PACKAGEDIR%\%QB_STRING%-x64-setup.log
IF ERRORLEVEL 1 GOTO FAIL
GOTO CLEANUP
:END
CALL %SCRIPTROOT%\virgin.bat restore