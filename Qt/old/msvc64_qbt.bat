@ECHO OFF
IF NOT EXIST %BUILDROOT%\Qt MD %BUILDROOT%\Qt
SET "INST_DIR=%BUILDROOT%\Qt\Qt64_qbt"
IF EXIST %INST_DIR% RD /S /Q %INST_DIR%
CALL %SCRIPTROOT%\virgin.bat backup
SET CWD=%CD%
CALL "C:\Program Files (x86)\Microsoft Visual Studio 10.0\VC\bin\amd64\vcvars64.bat"
IF EXIST %SOURCEROOT%\Qt RD /S /Q %SOURCEROOT%\Qt
MD %SOURCEROOT%\Qt
CD %SOURCEROOT%\Qt
"C:\Program Files\7-Zip\7z.exe" x -x!examples -x!demos -x!doc -x!include\QtXmlPatterns -x!include\QtWebKit -x!include\QtUiTools -x!include\QtScriptTools -x!include\QtScript  -x!include\QtOpenVG -x!include\QtOpenGL -x!include\QtMultimedia -x!include\QtMeeGoGraphicsSystemHelper -x!include\QtHelp -x!include\QtDesigner -x!include\QtDeclarative -x!include\QtDBus -x!include\Qt3Support -x!include\phonon -x!include\phonon_compat -x!src\dbus -x!src\declarative -x!src\multimedia -x!src\opengl -x!src\openvg -x!src\qt3support -x!src\script -x!src\scripttools -x!src\xmlpatterns -x!src\s60installs -x!src\s60main -x!src\3rdparty\webkit -x!src\3rdparty\ce-compat -x!src\3rdparty\clucene -x!src\3rdparty\javascriptcore -x!src\3rdparty\phonon -x!src\3rdparty\pixman -x!src\3rdparty\s60 -x!src\3rdparty\wayland -x!src\3rdparty\xorg T:\_compressed_sources\QT-4.8.4.7z
patch --binary -p1 -Nsfi %CWD%\patches\msvc64_R.diff
:: Looks like qBt needs Qt with stl enabled
.\configure.exe -release -shared -opensource -confirm-license -platform win32-msvc2010 -arch windows -ltcg -no-fast -exceptions -no-accessibility -stl -no-xmlpatterns -no-sql-mysql -no-sql-psql -no-sql-oci -no-sql-odbc -no-sql-tds -no-sql-db2 -no-sql-sqlite -no-sql-sqlite2 -no-sql-ibase -no-qt3support -no-opengl -no-openvg -graphicssystem raster -qt-zlib -qt-libpng -qt-libmng -qt-libtiff -qt-libjpeg -qt-gif -no-dsp -no-vcproj -incredibuild-xge -plugin-manifests -process -mp -no-rtti -no-3dnow -mmx -sse -sse2 -openssl -no-dbus -no-phonon -no-phonon-backend -no-multimedia -no-audio-backend -no-webkit -no-script -no-scripttools -no-declarative -no-declarative-debug -no-style-s60 -no-style-windowsmobile -no-style-windowsce -no-style-cde -no-style-motif -qt-style-cleanlooks -qt-style-plastique -qt-style-windows -qt-style-windowsxp -qt-style-windowsvista -no-native-gestures -directwrite -qmake -nomake examples -nomake demos -nomake tools -nomake docs -I %BUILDROOT%\OpenSSL\OpenSSL64\include -L %BUILDROOT%\OpenSSL\OpenSSL64\lib -prefix %INST_DIR%
nmake sub-src
nmake sub-translations-make_default-ordered
nmake install
CD ..
RD /S /Q Qt
CD %CWD%
SET INST_DIR=
CALL %SCRIPTROOT%\virgin.bat restore