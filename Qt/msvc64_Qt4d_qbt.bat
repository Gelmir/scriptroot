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
SET "INST_DIR=%BUILDROOT%\Qt\Qt4d_x64_qbt"
IF EXIST %INST_DIR% RD /S /Q %INST_DIR%
CALL %SCRIPTROOT%\virgin.bat backup
SET CWD=%CD%
CALL "C:\Program Files (x86)\Microsoft Visual Studio 11.0\VC\bin\x86_amd64\vcvarsx86_amd64.bat"
IF EXIST %SOURCEROOT%\Qt RD /S /Q %SOURCEROOT%\Qt
MD %SOURCEROOT%\Qt
CD %SOURCEROOT%\Qt
"C:\Program Files\7-Zip\7z.exe" x %ARCHIVES%\QT-4.8.6.7z -o%SOURCEROOT%\Qt
SET "PATH=%BUILDROOT%\jom;%PATH%"
.\configure.exe -debug -shared -opensource -confirm-license -platform win32-msvc2012 -arch windows -no-ltcg -no-fast -exceptions -no-accessibility -stl -no-sql-mysql -no-sql-psql -no-sql-oci -no-sql-odbc -no-sql-tds -no-sql-db2 -qt-sql-sqlite -no-sql-sqlite2 -no-sql-ibase -no-qt3support -no-opengl -no-openvg -graphicssystem raster -qt-zlib -qt-libpng -qt-libmng -qt-libtiff -qt-libjpeg -no-dsp -no-vcproj -no-incredibuild-xge -plugin-manifests -process -no-mp -rtti -no-3dnow -mmx -sse -sse2 -openssl -no-dbus -no-phonon -no-phonon-backend -no-multimedia -no-audio-backend -no-webkit -no-script -no-scripttools -no-declarative -no-declarative-debug -no-style-s60 -no-style-windowsmobile -no-style-windowsce -no-style-cde -no-style-motif -qt-style-cleanlooks -qt-style-plastique -qt-style-windows -qt-style-windowsxp -qt-style-windowsvista -no-native-gestures -no-directwrite -qmake -nomake examples -nomake demos -I %BUILDROOT%\OpenSSL\OpenSSL64d\include -L %BUILDROOT%\OpenSSL\OpenSSL64d\lib -prefix %INST_DIR%
IF ERRORLEVEL 1 GOTO FAIL
jom -j4 make_default
IF ERRORLEVEL 1 GOTO FAIL
jom -j1 sub-translations-make_default-ordered
IF ERRORLEVEL 1 GOTO FAIL
jom -j1 install
IF ERRORLEVEL 1 GOTO FAIL
GOTO CLEANUP
:END
CALL %SCRIPTROOT%\virgin.bat restore