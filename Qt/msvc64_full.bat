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
SET "INST_DIR=%BUILDROOT%\Qt\Qt64"
IF EXIST %INST_DIR% RD /S /Q %INST_DIR%
CALL %SCRIPTROOT%\virgin.bat backup
SET CWD=%CD%
CALL "C:\Program Files (x86)\Microsoft Visual Studio 10.0\VC\bin\amd64\vcvars64.bat"
IF EXIST %SOURCEROOT%\Qt RD /S /Q %SOURCEROOT%\Qt
MD %SOURCEROOT%\Qt
CD %SOURCEROOT%\Qt
"C:\Program Files\7-Zip\7z.exe" x T:\_compressed_sources\QT-4.8.5.7z -o%SOURCEROOT%\Qt
patch --binary -p1 -Nfi %SCRIPTROOT%\Qt\patches\msvc64_R.diff
IF ERRORLEVEL 1 GOTO FAIL
:: Remove shitload of _HAS_TR1 redifinition warnings on msvc2010
sed -b -e "/^win32-\*\: DEFINES += _HAS_TR1=0.*/d" < .\src\3rdparty\webkit\Source\JavaScriptCore\JavaScriptCore.pri > .\src\3rdparty\webkit\Source\JavaScriptCore\JavaScriptCore.pri.%SEDEXT%
MOVE /Y .\src\3rdparty\webkit\Source\JavaScriptCore\JavaScriptCore.pri.%SEDEXT% .\src\3rdparty\webkit\Source\JavaScriptCore\JavaScriptCore.pri
:: Remove .orig files created by patch
FOR /R .\ %%X IN (*.orig) DO (
	DEL /Q %%X
)
SET "PATH=%BUILDROOT%\jom;%PATH%"
.\configure.exe -release -shared -opensource -confirm-license -platform win32-msvc2010 -arch windows -ltcg -no-fast -exceptions -no-accessibility -stl -no-sql-mysql -no-sql-psql -no-sql-oci -no-sql-odbc -no-sql-tds -no-sql-db2 -qt-sql-sqlite -no-sql-sqlite2 -no-sql-ibase -no-qt3support -opengl desktop -no-openvg -graphicssystem raster -qt-zlib -qt-libpng -qt-libmng -qt-libtiff -qt-libjpeg -no-dsp -no-vcproj -no-incredibuild-xge -plugin-manifests -process -no-mp -rtti -no-3dnow -mmx -sse -sse2 -openssl -no-dbus -phonon -phonon-backend -multimedia -audio-backend -webkit -script -scripttools -declarative -declarative-debug -no-style-s60 -no-style-windowsmobile -no-style-windowsce -no-style-cde -no-style-motif -qt-style-cleanlooks -qt-style-plastique -qt-style-windows -qt-style-windowsxp -qt-style-windowsvista -no-native-gestures -no-directwrite -qmake -nomake examples -nomake demos -I %BUILDROOT%\OpenSSL\OpenSSL64\include -L %BUILDROOT%\OpenSSL\OpenSSL64\lib -prefix %INST_DIR%
IF ERRORLEVEL 1 GOTO FAIL
jom -j4 make_default
IF ERRORLEVEL 1 GOTO FAIL
jom -j1 sub-translations-make_default-ordered
IF ERRORLEVEL 1 GOTO FAIL
:: make docs fails because dlls are not copied into bin folder
XCOPY /Y /Q .\lib\*.dll .\bin\
jom -j1 docs
IF ERRORLEVEL 1 GOTO FAIL
jom -j1 install
IF ERRORLEVEL 1 GOTO FAIL
GOTO CLEANUP
:END
CALL %SCRIPTROOT%\virgin.bat restore