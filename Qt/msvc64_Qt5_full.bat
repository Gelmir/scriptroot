@ECHO OFF
GOTO BEGIN
:CLEANUP
CD %CWD%
SET INST_DIR=
IF EXIST %SOURCEROOT%\Qt RD /S /Q %SOURCEROOT%\Qt
GOTO END
:FAIL
ECHO Building failed, leaving source tree as is and dumping custom env vars
CD %CWD%
IF DEFINED INST_DIR ECHO INST_DIR = %INST_DIR%
SET INST_DIR=
GOTO END
:BEGIN
IF NOT EXIST %BUILDROOT%\Qt MD %BUILDROOT%\Qt
SET "INST_DIR=%BUILDROOT%\Qt\Qt5_x64_full"
IF EXIST %INST_DIR% RD /S /Q %INST_DIR%
CALL %SCRIPTROOT%\virgin.bat backup
SET CWD=%CD%
CALL "C:\Program Files (x86)\Microsoft Visual Studio 12.0\VC\bin\x86_amd64\vcvarsx86_amd64.bat"
IF EXIST %SOURCEROOT%\Qt RD /S /Q %SOURCEROOT%\Qt
MD %SOURCEROOT%\Qt
CD %SOURCEROOT%\Qt
"C:\Program Files\7-Zip\7z.exe" x %ARCHIVES%\QT-5.5.0.7z -o%SOURCEROOT%\Qt
IF ERRORLEVEL 1 GOTO FAIL
SET "PATH=%BUILDROOT%\icu\icu64\bin64;%BUILDROOT%\ruby\bin;%SOURCEROOT%\qt\gnuwin32\bin;%INST_DIR%\bin;%BUILDROOT%\jom;%PATH%"
CALL configure.bat -developer-build -release -shared -opensource -confirm-license -platform win32-msvc2013 -ltcg -accessibility -no-sql-mysql -no-sql-psql -no-sql-oci -no-sql-odbc -no-sql-tds -no-sql-db2 -qt-sql-sqlite -no-sql-sqlite2 -no-sql-ibase -opengl desktop -angle -no-openvg -qt-zlib -qt-libpng -qt-libjpeg -icu -qt-pcre -qt-freetype -no-incredibuild-xge -plugin-manifests -no-mp -rtti -sse2 -no-sse3 -no-ssse3 -no-sse4.1 -no-sse4.2 -no-avx -no-avx2 -openssl -no-dbus -audio-backend -wmf-backend -qml-debug -no-style-windowsmobile -no-style-windowsce -qt-style-fusion -qt-style-windows -qt-style-windowsxp -qt-style-windowsvista -no-native-gestures -directwrite -qmake -nomake examples -nomake tests -skip qtwebkit-examples -no-warnings-are-errors -I %BUILDROOT%\OpenSSL\OpenSSL64\include -I %BUILDROOT%\icu\icu64\include -L %BUILDROOT%\OpenSSL\OpenSSL64\lib -L %BUILDROOT%\icu\icu64\lib64 -prefix %INST_DIR%
IF ERRORLEVEL 1 GOTO FAIL
jom -j4
IF ERRORLEVEL 1 GOTO FAIL
jom -j1 install
IF ERRORLEVEL 1 GOTO FAIL
jom -j1 docs
IF ERRORLEVEL 1 GOTO FAIL
jom -j1 install_qch_docs
IF ERRORLEVEL 1 GOTO FAIL
GOTO CLEANUP
:END
CALL %SCRIPTROOT%\virgin.bat restore