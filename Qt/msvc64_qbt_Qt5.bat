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
SET "INST_DIR=%BUILDROOT%\Qt\Qt64_Qt5_qbt"
IF EXIST %INST_DIR% RD /S /Q %INST_DIR%
CALL %SCRIPTROOT%\virgin.bat backup
SET CWD=%CD%
CALL "C:\Program Files (x86)\Microsoft Visual Studio 10.0\VC\bin\amd64\vcvars64.bat"
IF EXIST %SOURCEROOT%\Qt RD /S /Q %SOURCEROOT%\Qt
MD %SOURCEROOT%\Qt
CD %SOURCEROOT%\Qt
"C:\Program Files\7-Zip\7z.exe" x T:\_compressed_sources\QT-5.1.0.7z -o%SOURCEROOT%\Qt qtbase qtsvg qtactiveqt qttools qtimageformats qttranslations README .sha1s .tag configure* LGPL_EXCEPTION.txt LICENSE* qt.pro README
patch --binary -p1 -Nsfi %SCRIPTROOT%\Qt\patches\msvc64_R_Qt5.diff
IF ERRORLEVEL 1 GOTO FAIL
:: Skip some stuff
:: -skip qtdeclarative -skip qtjsbackend -skip qtmultimedia -skip qtquick1 -skip qtquickcontrols -skip qtscript -skip qtwebkit -skip qtxmlpatterns -skip qtx11extras -skip qtsensors -skip qtserialport
CALL configure.bat -release -shared -opensource -confirm-license -platform win32-msvc2010 -ltcg -no-accessibility -no-sql-mysql -no-sql-psql -no-sql-oci -no-sql-odbc -no-sql-tds -no-sql-db2 -qt-sql-sqlite -no-sql-sqlite2 -no-sql-ibase -no-opengl -no-angle -no-openvg -qt-zlib -qt-libpng -qt-libjpeg -no-icu -qt-pcre -qt-freetype -no-vcproj -no-incredibuild-xge -plugin-manifests -process -no-mp -rtti -sse2 -no-sse3 -no-ssse3 -no-sse4.1 -no-sse4.2 -no-avx -no-avx2 -openssl -no-dbus -no-audio-backend -no-qml-debug -no-style-windowsmobile -no-style-windowsce -qt-style-fusion -qt-style-windows -qt-style-windowsxp -qt-style-windowsvista -no-native-gestures -no-directwrite -qmake -nomake examples -nomake demos -nomake docs -nomake tests -no-warnings-are-errors -I %BUILDROOT%\OpenSSL\OpenSSL64\include -L %BUILDROOT%\OpenSSL\OpenSSL64\lib -prefix %INST_DIR%
IF ERRORLEVEL 1 GOTO FAIL
jom -j4
IF ERRORLEVEL 1 GOTO FAIL
jom -j1 module-qttranslations
IF ERRORLEVEL 1 GOTO FAIL
jom -j1 install
IF ERRORLEVEL 1 GOTO FAIL
GOTO CLEANUP
:END
CALL %SCRIPTROOT%\virgin.bat restore