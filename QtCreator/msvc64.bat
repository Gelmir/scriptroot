@ECHO OFF
GOTO BEGIN
:CLEANUP
CD %CWD%
SET DISABLE_PLUGINS=
SET INSTALL_ROOT=
SET QMAKESPEC=
IF EXIST %SOURCEROOT%\Qt RD /S /Q %SOURCEROOT%\Qt
IF EXIST %SOURCEROOT%\QtCreator RD /S /Q %SOURCEROOT%\QtCreator
IF EXIST %SOURCEROOT%\mkspecs RD /S /Q %SOURCEROOT%\mkspecs
GOTO END
:FAIL
ECHO Building failed, leaving source tree as is and dumping custom env vars
CD %CWD%
IF DEFINED DISABLE_PLUGINS ECHO DISABLE_PLUGINS = %DISABLE_PLUGINS%
IF DEFINED INSTALL_ROOT ECHO INSTALL_ROOT = %INSTALL_ROOT%
IF DEFINED QMAKESPEC ECHO QMAKESPEC = %QMAKESPEC%
SET DISABLE_PLUGINS=
SET INSTALL_ROOT=
SET QMAKESPEC=
GOTO END
:BEGIN
IF EXIST %BUILDROOT%\QtCreator RD /S /Q %BUILDROOT%\QtCreator
CALL %SCRIPTROOT%\virgin.bat backup
SET CWD=%CD%
CALL "C:\Program Files (x86)\Microsoft Visual Studio 10.0\VC\bin\amd64\vcvars64.bat"
SET "PATH=%BUILDROOT%\Qt\Qt4_x64_full\bin;C:\_\Python27;C:\Program Files\7-Zip;%BUILDROOT%\jom;%PATH%"
IF EXIST %SOURCEROOT%\Qt RD /S /Q %SOURCEROOT%\Qt
MD %SOURCEROOT%\Qt
CD %SOURCEROOT%\Qt
"C:\Program Files\7-Zip\7z.exe" x %ARCHIVES%\QT-4.8.5.7z -o%SOURCEROOT%\Qt
IF EXIST %SOURCEROOT%\QtCreator RD /S /Q %SOURCEROOT%\QtCreator
MD %SOURCEROOT%\QtCreator
CD %SOURCEROOT%\QtCreator
XCOPY /E /Y /Q /I C:\Users\Dayman\Documents\GitHub\QtCreator %SOURCEROOT%\QtCreator\
:: madde -> maemo dev integration, fakevim -> vimlike accelerators, valgrind -> code profiler (not available on windows)
:: SET DISABLE_PLUGINS=plugin_valgrind plugin_perforce plugin_git plugin_madde plugin_fakevim plugin_cvs
REM SET "DISABLE_PLUGINS=plugin_valgrind plugin_madde plugin_fakevim"
SET "INSTALL_ROOT=%BUILDROOT%\QtCreator"
REM FOR %%X IN (%DISABLE_PLUGINS%) DO (
    REM sed -b -e "/^[[:space:]]\+%%X/d" < .\src\plugins\plugins.pro > .\src\plugins\plugins.pro.%SEDEXT%
	REM MOVE /Y %SOURCEROOT%\QtCreator\plugins.pro.%SEDEXT% %SOURCEROOT%\QtCreator\plugins.pro
REM )
MD qtcb
CD qtcb
qmake -config release -r ../qtcreator.pro "QT_PRIVATE_HEADERS = C:/_/sources/Qt/include " "CONFIG += warn_off ltcg mmx sse sse2" "CONFIG -= 3dnow"
IF ERRORLEVEL 1 GOTO FAIL
jom -j4
IF ERRORLEVEL 1 GOTO FAIL
jom -j1 docs
IF ERRORLEVEL 1 GOTO FAIL
:: Disabling failing installation parts
:: Accessibility is not needed
sed -b -e "/^[[:space:]]\+plugins = \[/s|'accessible', \(.*\)|\1|" < ..\scripts\deployqt.py > ..\scripts\deployqt.py.%SEDEXT%
MOVE /Y %SOURCEROOT%\QtCreator\scripts\deployqt.py.%SEDEXT% %SOURCEROOT%\QtCreator\scripts\deployqt.py
:: Sqlite is built-in in QtSql4 and not built as a plugin, skip
sed -b -e "/^[[:space:]]\+plugins = /s|\(.*\), 'sqldrivers'|\1|" < ..\scripts\deployqt.py > ..\scripts\deployqt.py.%SEDEXT%
MOVE /Y %SOURCEROOT%\QtCreator\scripts\deployqt.py.%SEDEXT% %SOURCEROOT%\QtCreator\scripts\deployqt.py
:: Translations are not needed
REM sed -b -e "/^[[:space:]]\+copy_translations/s|\(.*\)|#\1|" < ..\scripts\deployqt.py > ..\scripts\deployqt.py.%SEDEXT%
REM MOVE /Y %SOURCEROOT%\QtCreator\scripts\deployqt.py.%SEDEXT% %SOURCEROOT%\QtCreator\scripts\deployqt.py
jom -j1 bindist
IF ERRORLEVEL 1 GOTO FAIL
jom -j1 install_docs
IF ERRORLEVEL 1 GOTO FAIL
CD %SOURCEROOT%\QtCreator\
CALL %SCRIPTROOT%\virgin.bat restore
RD /S /Q qtcb
CALL %SCRIPTROOT%\virgin.bat backup
MD qtcb
CD qtcb
CALL "C:\Program Files (x86)\Microsoft Visual Studio 10.0\VC\bin\vcvars32.bat"
SET "PATH=%BUILDROOT%\Qt\Qt4_x64_full\bin;C:\_\Python27;C:\Program Files\7-Zip;%BUILDROOT%\jom;%PATH%"
:: Prepare 32-bit mkspecs
IF EXIST %SOURCEROOT%\mkspecs RD /S /Q %SOURCEROOT%\mkspecs
"C:\Program Files\7-Zip\7z.exe" x -o%SOURCEROOT% %ARCHIVES%\QT-4.8.5.7z mkspecs
patch --binary -p1 -Nsfi %SCRIPTROOT%\Qt\patches\msvc_R.diff -d %SOURCEROOT%\
:: ignore errors here
:: IF ERRORLEVEL 1 GOTO FAIL
SET "QMAKESPEC=%SOURCEROOT%\mkspecs\win32-msvc2010"
qmake -config release -r ../qtcreator.pro "QT_PRIVATE_HEADERS = C:/_/sources/Qt/include " "CONFIG += warn_off msvc_mp ltcg mmx sse sse2" "CONFIG -= 3dnow"
IF ERRORLEVEL 1 GOTO FAIL
CD .\src\libs\qtcreatorcdbext
:: Only building i686 cdb helper
jom -j4
IF ERRORLEVEL 1 GOTO FAIL
jom -j1 install
IF ERRORLEVEL 1 GOTO FAIL
:: Ship Qt documentation with QtCreator
FOR %%X IN (assistant qt designer linguist qmake qml) DO (
    IF EXIST %INSTALL_ROOT%\share\doc\%%X RD /S /Q %INSTALL_ROOT%\share\doc\%%X
    MD %INSTALL_ROOT%\share\doc\%%X
    COPY /Y %BUILDROOT%\Qt\Qt4_x64_full\doc\qch\%%X.qch %INSTALL_ROOT%\share\doc\%%X\
)
:: Copy SSL libs
XCOPY /Y /Q %BUILDROOT%\OpenSSL\OpenSSL64\bin\*.dll %INSTALL_ROOT%\bin\
:: Copy whatever 'nmake bindist' forgot to copy
FOR %%X IN (bearer codecs phonon_backend) DO (
	XCOPY /E /Y /Q /I %BUILDROOT%\Qt\Qt4_x64_full\plugins\%%X %INSTALL_ROOT%\bin\%%X
)
:: Purge .lib files
FOR /R %INSTALL_ROOT% %%X IN (*.lib) DO DEL /Q %%X
IF ERRORLEVEL 1 GOTO FAIL
GOTO CLEANUP
:END
CALL %SCRIPTROOT%\virgin.bat restore