@ECHO OFF
GOTO BEGIN
:CLEANUP
CD %CWD%
SET INST_DIR=
IF EXIST %SOURCEROOT%\Quassel RD /S /Q %SOURCEROOT%\Quassel
GOTO END
:FAIL
ECHO Building failed, leaving source tree as is and dumping custom env vars
CD %CWD%
IF DEFINED INST_DIR ECHO INST_DIR = %INST_DIR%
SET INST_DIR=
GOTO END
:BEGIN
SET "INST_DIR=%BUILDROOT%\Quassel64"
IF EXIST %INST_DIR% RD /S /Q %INST_DIR%
MD %INST_DIR%
CALL %SCRIPTROOT%\virgin.bat backup
SET CWD=%CD%
CALL "C:\Program Files (x86)\Microsoft Visual Studio 12.0\VC\bin\x86_amd64\vcvarsx86_amd64.bat"
IF EXIST %SOURCEROOT%\Quassel RD /S /Q %SOURCEROOT%\Quassel
MD %SOURCEROOT%\Quassel
CD %SOURCEROOT%\Quassel
:: /H also copied hidden files (.git)
XCOPY /E /Y /Q /I /H D:\Users\Nick\Documents\GitHub\Quassel %SOURCEROOT%\Quassel\
:: Upstream bug http://bugs.quassel-irc.org/issues/1351
git apply --verbose %SCRIPTROOT%\quassel\patches\0001-Fix-build-with-Qt-5.5.patch
IF ERRORLEVEL 1 GOTO FAIL
MD build
CD build
SET "PATH=%BUILDROOT%\Qt\Qt5_x64_full\bin;%BUILDROOT%\qca64\bin;%BUILDROOT%\icu\icu64\bin64;%BUILDROOT%\Zlib\Zlib64;%BUILDROOT%\jom;C:\Program Files (x86)\CMake 2.8\bin;%PATH%"
SET "LIB=%BUILDROOT%\qca64\lib;%LIB%"
SET "INCLUDE=%BUILDROOT%\qca64\include;%INCLUDE%"
cmake -D CMAKE_INSTALL_PREFIX:STRING="D:/Users/Nick/Programs/Quassel64/bin" -Wno-dev -D EMBED_DATA=ON -D USE_QT5=ON -D CMAKE_BUILD_TYPE:STRING="Release" -D CMAKE_VERBOSE_MAKEFILE:BOOL=OFF -DWANT_CORE=ON -DWANT_QTCLIENT=ON -DWANT_MONO=ON -DWITH_PHONON=ON -DWITH_WEBKIT=ON -DWITH_KDE=OFF -DWITH_SYSLOG=OFF -DWITH_DBUS=OFF -DWITH_LIBINDICATE=OFF -DWITH_CRYPT=ON -DSTATIC=OFF -DLINK_EXTRA=crypt32 -D CMAKE_CXX_FLAGS:STRING="/favor:blend /GL" -D CMAKE_EXE_LINKER_FLAGS:STRING="/INCREMENTAL:NO /NOLOGO /LTCG /OPT:REF /OPT:ICF=5" -D CMAKE_MODULE_LINKER_FLAGS:STRING="/INCREMENTAL:NO /NOLOGO /LTCG /OPT:REF /OPT:ICF=5" -D CMAKE_SHARED_LINKER_FLAGS:STRING="/INCREMENTAL:NO /NOLOGO /LTCG /OPT:REF /OPT:ICF=5" -G "NMake Makefiles JOM" --build .\ ..\
IF ERRORLEVEL 1 GOTO FAIL
jom -j4
IF ERRORLEVEL 1 GOTO FAIL
jom -j1 install
IF ERRORLEVEL 1 GOTO FAIL
:: Copying leftovers
FOR %%X IN (Qt5Core.dll Qt5Gui.dll Qt5Widgets.dll Qt5Network.dll Qt5Sql.dll Qt5Script.dll Qt5WebKit.dll Qt5WebKitWidgets.dll Qt5Xml.dll Qt5Svg.dll Qt5Multimedia.dll Qt5MultimediaWidgets.dll Qt5OpenGL.dll Qt5Positioning.dll Qt5PrintSupport.dll Qt5Qml.dll Qt5Quick.dll Qt5Sensors.dll) DO (
    COPY /Y %BUILDROOT%\Qt\Qt5_x64_full\bin\%%X %INST_DIR%\bin\
)
XCOPY /Y /Q %BUILDROOT%\OpenSSL\OpenSSL64\bin\*.dll %INST_DIR%\bin\
COPY /Y %BUILDROOT%\qca64\bin\qca.dll %INST_DIR%\bin\
XCOPY /E /Y /Q /I %BUILDROOT%\qca64\certs %INST_DIR%\certs\
XCOPY /E /Y /Q /I %BUILDROOT%\Qt\Qt5_x64_full\plugins %INST_DIR%\plugins\
FOR %%X IN (icudt55.dll icuin55.dll icuuc55.dll) DO (
  XCOPY /E /Y /Q /I %BUILDROOT%\icu\icu64\bin64\%%X %INST_DIR%\bin
)
XCOPY /E /Y /Q /I %BUILDROOT%\qca64\lib\qca\crypto %INST_DIR%\plugins\crypto\
echo [Paths] > %INST_DIR%\bin\qt.conf
echo Plugins = ../plugins >> %INST_DIR%\bin\qt.conf
GOTO CLEANUP
:END
CALL %SCRIPTROOT%\virgin.bat restore