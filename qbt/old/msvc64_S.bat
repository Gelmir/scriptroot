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
:BEGIN
SET "INST_DIR=%BUILDROOT%\qBittorrent64_S"
IF EXIST %INST_DIR% RD /S /Q %INST_DIR%
MD %INST_DIR%
CALL %SCRIPTROOT%\virgin.bat backup
SET CWD=%CD%
CALL "C:\Program Files (x86)\Microsoft Visual Studio 11.0\VC\bin\x86_amd64\vcvarsx86_amd64.bat"
IF EXIST %SOURCEROOT%\qbittorrent RD /S /Q %SOURCEROOT%\qbittorrent
MD %SOURCEROOT%\qbittorrent
CD %SOURCEROOT%\qbittorrent
XCOPY /E /Y /Q /I C:\Users\Dayman\Documents\GitHub\qBittorrent %SOURCEROOT%\qbittorrent\
"C:\Program Files\7-Zip\7z.exe" x T:\_compressed_sources\GeoIP.7z -o.\src\geoip\
patch --binary -p1 -Nsfi %SCRIPTROOT%\qbt\patches\msvc64_S.diff
IF ERRORLEVEL 1 GOTO FAIL
patch --binary -p1 -Nsfi %SCRIPTROOT%\qbt\patches\hyperlinks.diff
IF ERRORLEVEL 1 GOTO FAIL
patch --binary -p1 -Nsfi %SCRIPTROOT%\qbt\patches\uploaded.diff
IF ERRORLEVEL 1 GOTO FAIL
patch --binary -p1 -Nsfi %SCRIPTROOT%\qbt\patches\downloaded.diff
IF ERRORLEVEL 1 GOTO FAIL
patch --binary -p1 -Nsfi %SCRIPTROOT%\qbt\patches\qico_static.diff
IF ERRORLEVEL 1 GOTO FAIL
MD build
CD build
SET "PATH=%BUILDROOT%\Qt\Qt64_qbt_S\bin;%PATH%"
XCOPY /E /Y /Q /I %BUILDROOT%\Qt\Qt64_qbt_S\lib\*.lib %SOURCEROOT%\Qt\lib\
qmake -config release -r ../qbittorrent.pro "CONFIG += warn_off msvc_mp rtti ltcg mmx sse sse2" "CONFIG -= 3dnow"
nmake
RD /S /Q %SOURCEROOT%\Qt
IF ERRORLEVEL 1 GOTO FAIL
COPY /Y .\src\release\qbittorrent.exe %INST_DIR%\
XCOPY /Y /Q /I %BUILDROOT%\Qt\Qt64_qbt_S\translations\qt_* %INST_DIR%\translations\
DEL /Q %INST_DIR%\translations\qt_help*
echo [Paths] > %INST_DIR%\qt.conf
echo Translations = ./translations >> %INST_DIR%\qt.conf
:: Copy License
COPY /Y C:\Users\Dayman\Documents\GitHub\qBittorrent\COPYING %INST_DIR%\LICENSE.txt
:: Remove Unprintable ASCII 0x0C from License
sed -b -e "s/^\x0C\(.*\)/\1/" < %INST_DIR%\LICENSE.txt > %INST_DIR%\LICENSE.txt.%SEDEXT%
MOVE /Y %INST_DIR%\LICENSE.txt.%SEDEXT% %INST_DIR%\LICENSE.txt
GOTO CLEANUP
:END
CALL %SCRIPTROOT%\virgin.bat restore