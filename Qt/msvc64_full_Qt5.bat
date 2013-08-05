@ECHO OFF
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
SET "INST_DIR=%BUILDROOT%\Qt\Qt64_Qt5"
IF EXIST %INST_DIR% RD /S /Q %INST_DIR%
CALL %SCRIPTROOT%\virgin.bat backup
SET CWD=%CD%
CALL "C:\Program Files (x86)\Microsoft Visual Studio 10.0\VC\bin\amd64\vcvars64.bat"
IF EXIST %SOURCEROOT%\Qt RD /S /Q %SOURCEROOT%\Qt
MD %SOURCEROOT%\Qt
CD %SOURCEROOT%\Qt
"C:\Program Files\7-Zip\7z.exe" x T:\_compressed_sources\QT-5.1.0.7z -o%SOURCEROOT%\Qt
patch --binary -p1 -Nsfi %SCRIPTROOT%\Qt\patches\msvc64_R_Qt5.diff
SET "PATH=%BUILDROOT%\icu64\bin64;T:\ruby\bin;%PATH%"
CALL configure.bat -release -shared -opensource -confirm-license -platform win32-msvc2010 -ltcg -accessibility -no-sql-mysql -no-sql-psql -no-sql-oci -no-sql-odbc -no-sql-tds -no-sql-db2 -qt-sql-sqlite -no-sql-sqlite2 -no-sql-ibase -opengl desktop -no-angle -no-openvg -qt-zlib -qt-libpng -qt-libjpeg -icu -qt-pcre -qt-freetype -no-vcproj -no-incredibuild-xge -plugin-manifests -process -no-mp -rtti -sse2 -no-sse3 -no-ssse3 -no-sse4.1 -no-sse4.2 -no-avx -no-avx2 -openssl -no-dbus -audio-backend -qml-debug -no-style-windowsmobile -no-style-windowsce -qt-style-fusion -qt-style-windows -qt-style-windowsxp -qt-style-windowsvista -no-native-gestures -no-directwrite -qmake -nomake examples -nomake demos -skip qtwebkit-examples -no-warnings-are-errors -I %BUILDROOT%\OpenSSL\OpenSSL64\include -I %BUILDROOT%\icu64\include -L %BUILDROOT%\OpenSSL\OpenSSL64\lib -L %BUILDROOT%\icu64\lib64 -prefix %INST_DIR%
IF ERRORLEVEL 1 GOTO FAIL
jom -j4
IF ERRORLEVEL 1 GOTO FAIL
jom -j1 module-qttranslations
IF ERRORLEVEL 1 GOTO FAIL
jom -j1 install
IF ERRORLEVEL 1 GOTO FAIL
jom -j1 docs
IF ERRORLEVEL 1 GOTO FAIL
GOTO CLEANUP
:END
CALL %SCRIPTROOT%\virgin.bat restore