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
SET "INST_DIR=%BUILDROOT%\Qt\Qt5_gcc64_qbt"
IF EXIST %INST_DIR% RD /S /Q %INST_DIR%
CALL %SCRIPTROOT%\virgin.bat backup
SET CWD=%CD%
IF EXIST %SOURCEROOT%\Qt RD /S /Q %SOURCEROOT%\Qt
MD %SOURCEROOT%\Qt
CD %SOURCEROOT%\Qt
"C:\Program Files\7-Zip\7z.exe" x %ARCHIVES%\QT-5.4.0.7z -o%SOURCEROOT%\Qt qtbase qtsvg qtactiveqt qttools qtimageformats qttranslations README .sha1s .tag configure* LGPL_EXCEPTION.txt LICENSE* qt.pro README
patch -p1 -Nsfi %SCRIPTROOT%\Qt\patches\gcc64_Qt5.patch
IF ERRORLEVEL 1 GOTO FAIL
SET "PATH=C:\_\MinGW\bin;%PATH%"
CALL configure.bat -debug-and-release -shared -opensource -confirm-license -platform win32-g++ -no-ltcg -no-accessibility -no-sql-mysql -no-sql-psql -no-sql-oci -no-sql-odbc -no-sql-tds -no-sql-db2 -qt-sql-sqlite -no-sql-sqlite2 -no-sql-ibase -no-opengl -no-angle -no-openvg -qt-zlib -qt-libpng -qt-libjpeg -no-icu -qt-pcre -qt-freetype -no-incredibuild-xge -plugin-manifests -no-mp -rtti -sse2 -no-sse3 -no-ssse3 -no-sse4.1 -no-sse4.2 -no-avx -no-avx2 -openssl -no-dbus -no-audio-backend -no-wmf-backend -no-qml-debug -no-style-windowsmobile -no-style-windowsce -qt-style-fusion -qt-style-windows -qt-style-windowsxp -qt-style-windowsvista -no-native-gestures -no-directwrite -qmake -nomake examples -nomake tests -no-warnings-are-errors -I %BUILDROOT%\OpenSSL\OpenSSL64_G\include -L %BUILDROOT%\OpenSSL\OpenSSL64_G\lib -prefix %INST_DIR%
IF ERRORLEVEL 1 GOTO FAIL
mingw32-make -j4
IF ERRORLEVEL 1 GOTO FAIL
mingw32-make -j4 install
IF ERRORLEVEL 1 GOTO FAIL
GOTO CLEANUP
:END
CALL %SCRIPTROOT%\virgin.bat restore