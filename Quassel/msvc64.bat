@ECHO OFF
GOTO BEGIN
:CLEANUP
IF %SIDE_BUILD% == 1 (
	IF EXIST %INSTALL_ROOT% RD /S /Q %INSTALL_ROOT%
)
CD %CWD%
SET INST_DIR=
SET SIDE_BUILD=
SET QUA_VERSION=
SET GIT_TAG=
IF EXIST %SOURCEROOT%\Quassel RD /S /Q %SOURCEROOT%\Quassel
GOTO END
:FAIL
ECHO Building failed, leaving source tree as is and dumping custom env vars
CD %CWD%
IF DEFINED INST_DIR ECHO INST_DIR = %INST_DIR%
IF DEFINED SIDE_BUILD ECHO SIDE_BUILD = %SIDE_BUILD%
IF DEFINED QUA_VERSION ECHO QUA_VERSION = %QUA_VERSION%
IF DEFINED GIT_TAG ECHO GIT_TAG = %GIT_TAG%
SET INST_DIR=
SET SIDE_BUILD=
SET QUA_VERSION=
SET GIT_TAG=
GOTO END
:BEGIN
Setlocal EnableDelayedExpansion
IF NOT DEFINED SIDE_BUILD (
	SET SIDE_BUILD=0
)
IF %SIDE_BUILD% == 1 (
	SET "INST_DIR=%TEMP%\Quassel64"
) ELSE (
	SET "INST_DIR=%BUILDROOT%\Quassel64"
)
IF EXIST %INST_DIR% RD /S /Q %INST_DIR%
MD %INST_DIR%\bin
CALL %SCRIPTROOT%\virgin.bat backup
SET CWD=%CD%
CALL "C:\Program Files (x86)\Microsoft Visual Studio 12.0\VC\bin\x86_amd64\vcvarsx86_amd64.bat"
IF EXIST %SOURCEROOT%\Quassel RD /S /Q %SOURCEROOT%\Quassel
MD %SOURCEROOT%\Quassel
CD %SOURCEROOT%\Quassel
:: /H also copies hidden files (.git)
XCOPY /E /Y /Q /I /H D:\Users\Nick\Documents\GitHub\Quassel %SOURCEROOT%\Quassel\
FOR /F "delims=" %%X IN ('findstr /R "QUASSEL_VERSION_STRING" .\CMakeLists.txt ^| sed -e "s/^.*\x22\(.*\)\x22)/\1/"') DO @SET QUA_VERSION=%%X
FOR /F "delims=" %%X IN ('git describe --long') DO @SET GIT_TAG=%%X
MD build
CD build
SET "PATH=%BUILDROOT%\Qt\Qt5_x64_full\bin;%BUILDROOT%\qca64\bin;%BUILDROOT%\icu\icu64\bin64;%BUILDROOT%\Zlib\Zlib64;%BUILDROOT%\jom;C:\Program Files (x86)\CMake\bin;%PATH%"
SET "LIB=%BUILDROOT%\qca64\lib;%LIB%"
SET "INCLUDE=%BUILDROOT%\qca64\include\Qca-qt5\QtCrypto;%INCLUDE%"
SET "Qca-qt5_DIR=%BUILDROOT%\qca64\lib\cmake\Qca"
IF %SIDE_BUILD% == 1 (
	cmake -D CMAKE_INSTALL_PREFIX:STRING="D:/Users/Nick/Temp/Quassel64/bin" -Wno-dev -D EMBED_DATA=ON -D USE_QT5=ON -D CMAKE_BUILD_TYPE:STRING="Release" -D CMAKE_VERBOSE_MAKEFILE:BOOL=OFF -DWANT_CORE=ON -DWANT_QTCLIENT=ON -DWANT_MONO=ON -DWITH_WEBKIT=OFF -DWITH_KDE=OFF -DSTATIC=OFF -DLINK_EXTRA=crypt32 -D CMAKE_CXX_FLAGS:STRING="/favor:blend /GL" -D CMAKE_EXE_LINKER_FLAGS:STRING="/INCREMENTAL:NO /NOLOGO /LTCG /OPT:REF /OPT:ICF=5" -G "NMake Makefiles JOM" --build .\ ..\
) ELSE (
	cmake -D CMAKE_INSTALL_PREFIX:STRING="D:/Users/Nick/Programs/Quassel64/bin" -Wno-dev -D EMBED_DATA=ON -D USE_QT5=ON -D CMAKE_BUILD_TYPE:STRING="Release" -D CMAKE_VERBOSE_MAKEFILE:BOOL=OFF -DWANT_CORE=ON -DWANT_QTCLIENT=ON -DWANT_MONO=ON -DWITH_WEBKIT=OFF -DWITH_KDE=OFF -DSTATIC=OFF -DLINK_EXTRA=crypt32 -D CMAKE_CXX_FLAGS:STRING="/favor:blend /GL" -D CMAKE_EXE_LINKER_FLAGS:STRING="/INCREMENTAL:NO /NOLOGO /LTCG /OPT:REF /OPT:ICF=5" -G "NMake Makefiles JOM" --build .\ ..\
)
IF ERRORLEVEL 1 GOTO FAIL
jom -j4
IF ERRORLEVEL 1 GOTO FAIL
jom -j1 install
IF ERRORLEVEL 1 GOTO FAIL
:: Copying leftovers
FOR %%X IN (Qt5Core.dll Qt5Gui.dll Qt5Widgets.dll Qt5Network.dll Qt5Sql.dll Qt5Script.dll Qt5Xml.dll Qt5Svg.dll Qt5Multimedia.dll Qt5MultimediaWidgets.dll Qt5OpenGL.dll Qt5Positioning.dll Qt5PrintSupport.dll Qt5Qml.dll Qt5Quick.dll Qt5Sensors.dll) DO (
    COPY /Y %BUILDROOT%\Qt\Qt5_x64_full\bin\%%X %INST_DIR%\bin\
)
XCOPY /Y /Q %BUILDROOT%\OpenSSL\OpenSSL64\bin\*.dll %INST_DIR%\bin\
COPY /Y %BUILDROOT%\qca64\bin\qca-qt5.dll %INST_DIR%\bin\
XCOPY /E /Y /Q /I %BUILDROOT%\qca64\certs %INST_DIR%\certs\
XCOPY /E /Y /Q /I %BUILDROOT%\Qt\Qt5_x64_full\plugins %INST_DIR%\plugins\
FOR %%X IN (icudt55.dll icuin55.dll icuuc55.dll) DO (
  XCOPY /E /Y /Q /I %BUILDROOT%\icu\icu64\bin64\%%X %INST_DIR%\bin
)
XCOPY /E /Y /Q /I %BUILDROOT%\qca64\lib\qca-qt5\crypto %INST_DIR%\plugins\crypto\
COPY /Y %SOURCEROOT%\Quassel\gpl-3.0.txt %INST_DIR%\LICENSE.txt
unix2dos -ascii %INST_DIR%\LICENSE.txt
COPY /Y "%VCINSTALLDIR%\redist\x64\Microsoft.VC120.CRT\msvcp120.dll" %INST_DIR%\bin\
COPY /Y "%VCINSTALLDIR%\redist\x64\Microsoft.VC120.CRT\msvcr120.dll" %INST_DIR%\bin\
echo [Paths] > %INST_DIR%\bin\qt.conf
echo Plugins = ../plugins >> %INST_DIR%\bin\qt.conf
SET "QUA_STRING=Quassel-%QUA_VERSION%_%GIT_TAG%"
ECHO Creating installer...
ECHO Installer log: %PACKAGEDIR%\%QUA_STRING%-x64-setup.log
IF EXIST "%PACKAGEDIR%\%QUA_STRING%-x64-setup.exe" DEL /Q "%PACKAGEDIR%\%QUA_STRING%-x64-setup.exe"
"C:\Program Files (x86)\Inno Setup 5\ISCC.exe" "/dMyFilesRoot=%INST_DIR%" "/dPACKDIR=%PACKAGEDIR%" "/dMyAppVersion=%QUA_VERSION%" "/dMyIcon=%SOURCEROOT%\Quassel\pics\quassel.ico" "/f%QUA_STRING%-x64-setup" "/o%PACKAGEDIR%" "%SCRIPTROOT%\Quassel\quassel64.iss" > %PACKAGEDIR%\%QUA_STRING%-x64-setup.log
GOTO CLEANUP
:END
CALL %SCRIPTROOT%\virgin.bat restore