@ECHO OFF
SET "INST_DIR=%BUILDROOT%\qBittorrent"
IF EXIST %INST_DIR% RD /S /Q %INST_DIR%
MD %INST_DIR%
CALL %SCRIPTROOT%\virgin.bat backup
SET CWD=%CD%
CALL "C:\Program Files (x86)\Microsoft Visual Studio 10.0\VC\bin\vcvars32.bat"
IF EXIST %SOURCEROOT%\qbittorrent RD /S /Q %SOURCEROOT%\qbittorrent
MD %SOURCEROOT%\qbittorrent
CD %SOURCEROOT%\qbittorrent
XCOPY /E /Y C:\Users\Dayman\Documents\GitHub\qBittorrent .\
CD .\src\geoip\
"C:\Program Files\7-Zip\7z.exe" x T:\_compressed_sources\GeoIP.7z
CD ..\..\
patch --verbose -p1 -i %CWD%\patches\msvc32.diff
MD build
CD build
SET "PATH=%PATH%;%BUILDROOT%\Qt\Qt_qbt\bin"
qmake -r ../qbittorrent.pro "CONFIG+=warn_off rtti ltcg mmx sse" "CONFIG-=3dnow -sse2" "QMAKE_CFLAGS_RELEASE+=/MP" "QMAKE_CFLAGS_DEBUG+=/MP" "QMAKE_CXXFLAGS+=/MP"
nmake sub-src-sub_Release
CD .\src\release
COPY /Y qbittorrent.exe %INST_DIR%\
FOR %%X IN (QtCore4.dll QtGui4.dll QtNetwork4.dll QtXml4.dll) DO (
    COPY /Y %BUILDROOT%\Qt\Qt_qbt\bin\%%X %INST_DIR%\
)
FOR %%X IN (codecs iconengines imageformats) DO (
    MD %INST_DIR%\%%X
    COPY /Y %BUILDROOT%\Qt\Qt_qbt\plugins\%%X\*.dll %INST_DIR%\%%X\
	DEL /Q %INST_DIR%\%%X\*d4.dll
)
COPY /Y %BUILDROOT%\OpenSSL\OpenSSL\bin\libeay32.dll %INST_DIR%\
COPY /Y %BUILDROOT%\OpenSSL\OpenSSL\bin\ssleay32.dll %INST_DIR%\
COPY /Y %BUILDROOT%\libtorrent\libtorrent\lib\torrent.dll %INST_DIR%\
COPY /Y %BUILDROOT%\Boost\Boost\lib\*.dll %INST_DIR%\
CD ..\..\..\..\
RD /S /Q qbittorrent
CD %CWD%
SET INST_DIR=
CALL %SCRIPTROOT%\virgin.bat restore