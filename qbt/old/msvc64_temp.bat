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
SET "INST_DIR=%BUILDROOT%\qBittorrent64_T"
IF EXIST %INST_DIR% RD /S /Q %INST_DIR%
MD %INST_DIR%
CALL %SCRIPTROOT%\virgin.bat backup
SET CWD=%CD%
CALL "C:\Program Files (x86)\Microsoft Visual Studio 11.0\VC\bin\x86_amd64\vcvarsx86_amd64.bat"
IF EXIST %SOURCEROOT%\qbittorrent RD /S /Q %SOURCEROOT%\qbittorrent
MD %SOURCEROOT%\qbittorrent
CD %SOURCEROOT%\qbittorrent
XCOPY /E /Y /Q /I C:\Users\Dayman\Documents\GitHub\qBittorrent .\
"C:\Program Files\7-Zip\7z.exe" x T:\_compressed_sources\GeoIP.7z -o.\src\geoip\
patch --binary -p1 -Nsfi %SCRIPTROOT%\qbt\patches\test.diff
IF ERRORLEVEL 1 GOTO FAIL
MD build
CD build
SET "PATH=%BUILDROOT%\Qt\Qt64\bin;%PATH%"
qmake -config release -r ../qbittorrent.pro "CONFIG += warn_off msvc_mp rtti mmx sse sse2" "CONFIG -= 3dnow ltcg" "LIBS += dbghelp.lib" "QMAKE_CXXFLAGS_RELEASE = -MD -O2 -Zi /Fdrelease\qbittorrent.pdb" "QMAKE_LFLAGS = /DEBUG /INCREMENTAL:NO /DYNAMICBASE /NXCOMPAT"
nmake
IF ERRORLEVEL 1 GOTO FAIL
COPY /Y .\src\release\qbittorrent.exe %INST_DIR%\
COPY /Y .\src\release\qbittorrent.pdb %INST_DIR%\
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
GOTO CLEANUP
:END
CALL %SCRIPTROOT%\virgin.bat restore