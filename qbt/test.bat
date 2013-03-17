@ECHO OFF
GOTO BEGIN
:CLEANUP
CD %CWD%
SET INST_DIR=
IF EXIST %SOURCEROOT%\qbittorrent RD /S /Q %SOURCEROOT%\qbittorrent
GOTO END
:FAIL
ECHO Building failed, leaving source tree as is and dumping custom env vars
CD %CWD%
IF DEFINED INST_DIR ECHO INST_DIR = %INST_DIR%
SET INST_DIR=
GOTO END
:: Control git branhes
:GIT_CMDS
git checkout --merge "cmake"
XCOPY /E /Y /Q /I C:\Users\Dayman\Documents\GitHub\qBittorrent %SOURCEROOT%\qbittorrent\
GOTO CONTINUE
:BEGIN
:: Bitch please
:: Required for nested loops and ifs
REM Setlocal EnableDelayedExpansion
SET "INST_DIR=%BUILDROOT%\qBittorrent64_test"
IF EXIST %INST_DIR% RD /S /Q %INST_DIR%
MD %INST_DIR%
CALL %SCRIPTROOT%\virgin.bat backup
SET CWD=%CD%
CALL "C:\Program Files (x86)\Microsoft Visual Studio 10.0\VC\bin\amd64\vcvars64.bat"
IF EXIST %SOURCEROOT%\qbittorrent RD /S /Q %SOURCEROOT%\qbittorrent
MD %SOURCEROOT%\qbittorrent
CD /D "C:\Users\Dayman\Documents\GitHub\qBittorrent"
GOTO GIT_CMDS
:CONTINUE
CD /D %SOURCEROOT%\qbittorrent
"C:\Program Files\7-Zip\7z.exe" x T:\_compressed_sources\GeoIP.7z -o.\src\geoip\
:: Replace paths to libtorrent, boost, etc.
patch --binary -p1 -Nsfi %SCRIPTROOT%\qbt\patches\msvc64.patch
IF ERRORLEVEL 1 GOTO FAIL
SET "PATH=%BUILDROOT%\Qt\Qt64\bin;%PATH%"
CD .\src
lupdate -no-obsolete ./src.pro
IF ERRORLEVEL 1 GOTO FAIL
lrelease ./src.pro
IF ERRORLEVEL 1 GOTO FAIL
CD ..\
MD build
CD build
qmake -config release -r ../qbittorrent.pro "CONFIG += strace_win warn_off msvc_mp rtti ltcg mmx sse sse2" "CONFIG -= 3dnow"
IF ERRORLEVEL 1 GOTO FAIL
nmake
IF ERRORLEVEL 1 GOTO FAIL
COPY /Y .\src\release\qbittorrent.exe %INST_DIR%\
IF EXIST .\src\release\qbittorrent.pdb COPY /Y .\src\release\qbittorrent.pdb %INST_DIR%\
FOR %%X IN (QtCore4.dll QtGui4.dll QtNetwork4.dll QtXml4.dll) DO (
    COPY /Y %BUILDROOT%\Qt\Qt64\bin\%%X %INST_DIR%\
)
:: Only qico4.dll is required
XCOPY /Y /Q /I %BUILDROOT%\Qt\Qt64\plugins\imageformats\qico4.dll %INST_DIR%\plugins\imageformats\
XCOPY /Y /Q /I %BUILDROOT%\Qt\Qt64\translations\qt_* %INST_DIR%\translations\
DEL /Q %INST_DIR%\translations\qt_help*
echo [Paths] > %INST_DIR%\qt.conf
echo Translations = ./translations >> %INST_DIR%\qt.conf
echo Plugins = ./plugins >> %INST_DIR%\qt.conf
XCOPY /Y /Q %BUILDROOT%\OpenSSL\OpenSSL64\bin\*.dll %INST_DIR%\
COPY /Y %BUILDROOT%\libtorrent\libtorrent64\lib\torrent.dll %INST_DIR%\
XCOPY /Y /Q %BUILDROOT%\Boost\Boost64\lib\*.dll %INST_DIR%\
:: Copy VC++ 2010 x64 Redist DLLs
XCOPY /Y /Q "%VCINSTALLDIR%\redist\x64\Microsoft.VC100.CRT\*.dll" %INST_DIR%\
:: Copy License
COPY /Y %SOURCEROOT%\qbittorrent\COPYING %INST_DIR%\LICENSE.txt
:: Remove Unprintable ASCII 0x0C from License
sed -b -e "s/^\x0C\(.*\)/\1/" < %INST_DIR%\LICENSE.txt > %INST_DIR%\LICENSE.txt.%SEDEXT%
MOVE /Y %INST_DIR%\LICENSE.txt.%SEDEXT% %INST_DIR%\LICENSE.txt
GOTO CLEANUP
:END
CALL %SCRIPTROOT%\virgin.bat restore