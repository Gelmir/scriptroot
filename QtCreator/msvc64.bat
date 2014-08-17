@ECHO OFF
GOTO BEGIN
:CLEANUP
CD %CWD%
SET DISABLE_PLUGINS=
SET INSTALL_ROOT=
SET QMAKESPEC=
SET CDB_PATH=
REM IF EXIST %SOURCEROOT%\Qt RD /S /Q %SOURCEROOT%\Qt
IF EXIST %SOURCEROOT%\QtCreator RD /S /Q %SOURCEROOT%\QtCreator
IF EXIST %SOURCEROOT%\qtbase RD /S /Q %SOURCEROOT%\qtbase
GOTO END
:FAIL
ECHO Building failed, leaving source tree as is and dumping custom env vars
CD %CWD%
IF DEFINED DISABLE_PLUGINS ECHO DISABLE_PLUGINS = %DISABLE_PLUGINS%
IF DEFINED INSTALL_ROOT ECHO INSTALL_ROOT = %INSTALL_ROOT%
IF DEFINED QMAKESPEC ECHO QMAKESPEC = %QMAKESPEC%
IF DEFINED CDB_PATH ECHO CDB_PATH = %CDB_PATH%
SET DISABLE_PLUGINS=
SET INSTALL_ROOT=
SET QMAKESPEC=
SET CDB_PATH=
GOTO END
:BEGIN
IF EXIST %BUILDROOT%\QtCreator RD /S /Q %BUILDROOT%\QtCreator
CALL %SCRIPTROOT%\virgin.bat backup
SET CWD=%CD%
CALL "C:\Program Files (x86)\Microsoft Visual Studio 11.0\VC\bin\x86_amd64\vcvarsx86_amd64.bat
SET "PATH=%BUILDROOT%\Qt\Qt5_x64_full\bin;C:\_\Python27;C:\Program Files\7-Zip;%BUILDROOT%\jom;%BUILDROOT%\icu\icu64\bin64;C:\_\ruby\bin;%PATH%"
SET "CDB_PATH=C:\Program Files (x86)\Windows Kits\8.1\Debuggers"
IF EXIST %SOURCEROOT%\QtCreator RD /S /Q %SOURCEROOT%\QtCreator
MD %SOURCEROOT%\QtCreator
CD %SOURCEROOT%\QtCreator
XCOPY /E /Y /Q /I C:\Users\Dayman\Documents\GitHub\QtCreator %SOURCEROOT%\QtCreator\
SET "INSTALL_ROOT=%BUILDROOT%\QtCreator"
MD qtcb
CD qtcb
qmake -config release -r ../qtcreator.pro "CONFIG += warn_off mmx sse sse2 ltcg" "CONFIG -= 3dnow"
IF ERRORLEVEL 1 GOTO FAIL
jom -j4
IF ERRORLEVEL 1 GOTO FAIL
jom -j1 docs
IF ERRORLEVEL 1 GOTO FAIL
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
CALL "C:\Program Files (x86)\Microsoft Visual Studio 11.0\VC\bin\vcvars32.bat"
SET "PATH=%BUILDROOT%\Qt\Qt5_x64_full\bin;C:\_\Python27;C:\Program Files\7-Zip;%BUILDROOT%\jom;%BUILDROOT%\icu\icu64\bin64;C:\_\ruby\bin;%PATH%"
SET "CDB_PATH=C:\Program Files (x86)\Windows Kits\8.1\Debuggers"
:: Prepare 32-bit mkspecs
IF EXIST %SOURCEROOT%\qtbase RD /S /Q %SOURCEROOT%\qtbase
"C:\Program Files\7-Zip\7z.exe" x -o%SOURCEROOT% %ARCHIVES%\QT-5.3.1.7z qtbase\mkspecs
SET "QMAKESPEC=%SOURCEROOT%\qtbase\mkspecs\win32-msvc2012"
qmake -config release -r ../qtcreator.pro "CONFIG += warn_off msvc_mp ltcg mmx sse sse2" "CONFIG -= 3dnow"
IF ERRORLEVEL 1 GOTO FAIL
CD .\src\libs\qtcreatorcdbext
:: Only building i686 cdb helper
jom -j4
IF ERRORLEVEL 1 GOTO FAIL
jom -j1 install
IF ERRORLEVEL 1 GOTO FAIL
:: Ship Qt documentation with QtCreator
COPY /Y %BUILDROOT%\Qt\Qt5_x64_full\doc\*.qch %INSTALL_ROOT%\share\doc\
:: Copy SSL libs
XCOPY /Y /Q %BUILDROOT%\OpenSSL\OpenSSL64\bin\*.dll %INSTALL_ROOT%\bin\
:: Copy whatever 'nmake bindist' forgot to copy
XCOPY /E /Y /Q /I %BUILDROOT%\Qt\Qt5_x64_full\plugins %INSTALL_ROOT%\bin\plugins\
FOR %%X IN (icudt53.dll icuin53.dll icuuc53.dll) DO (
  XCOPY /E /Y /Q /I %BUILDROOT%\icu\icu64\bin64\%%X %INSTALL_ROOT%\bin
)
:: Purge .lib files
FOR /R %INSTALL_ROOT% %%X IN (*.lib) DO DEL /Q %%X
IF ERRORLEVEL 1 GOTO FAIL
GOTO CLEANUP
:END
CALL %SCRIPTROOT%\virgin.bat restore