@ECHO OFF
SET "INST_DIR=%BUILDROOT%\qBittorrent64_5"
IF EXIST %INST_DIR% RD /S /Q %INST_DIR%
MD %INST_DIR%
CALL %SCRIPTROOT%\virgin.bat backup
SET CWD=%CD%
CALL "C:\Program Files (x86)\Microsoft Visual Studio 10.0\VC\bin\amd64\vcvars64.bat"
IF EXIST %SOURCEROOT%\qbittorrent RD /S /Q %SOURCEROOT%\qbittorrent
MD %SOURCEROOT%\qbittorrent
CD %SOURCEROOT%\qbittorrent
XCOPY /E /Y /Q /I C:\Users\Dayman\Documents\GitHub\qBittorrent %SOURCEROOT%\qbittorrent
"C:\Program Files\7-Zip\7z.exe" x T:\_compressed_sources\GeoIP.7z -o%SOURCEROOT%\qbittorrent\src\geoip\
patch --binary -p1 -Nsfi %SCRIPTROOT%\qbt\patches\msvc64.patch
MD build
CD build
SET "PATH=%BUILDROOT%\Qt\Qt64_Qt5_qbt\bin;%PATH%"
qmake -config release -r ../qbittorrent.pro "CONFIG+=warn_off msvc_mp stl rtti ltcg mmx sse sse2" "CONFIG-=3dnow"
nmake
SET LC_ALL=
SET PACKAGE=
SET INST_DIR=
SET QBT_VERSION=
SET PACKAGE=
CD %CWD%
RD /S /Q %SOURCEROOT%\qbittorrent
CALL %SCRIPTROOT%\virgin.bat restore