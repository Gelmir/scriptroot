@ECHO OFF
GOTO BEGIN
:CLEANUP
IF %SIDE_BUILD% == 1 (
	IF EXIST %INSTALL_ROOT% RD /S /Q %INSTALL_ROOT%
)
CD %CWD%
SET INSTALL_ROOT=
SET QMAKESPEC=
SET CDB_PATH=
SET SIDE_BUILD=
SET QTC_VERSION=
SET GIT_TAG=
IF EXIST %SOURCEROOT%\Qt RD /S /Q %SOURCEROOT%\Qt
IF EXIST %SOURCEROOT%\QtCreator RD /S /Q %SOURCEROOT%\QtCreator
IF EXIST %SOURCEROOT%\qtbase RD /S /Q %SOURCEROOT%\qtbase
GOTO END
:FAIL
ECHO Building failed, leaving source tree as is and dumping custom env vars
CD %CWD%
IF DEFINED INSTALL_ROOT ECHO INSTALL_ROOT = %INSTALL_ROOT%
IF DEFINED QMAKESPEC ECHO QMAKESPEC = %QMAKESPEC%
IF DEFINED CDB_PATH ECHO CDB_PATH = %CDB_PATH%
IF DEFINED SIDE_BUILD ECHO SIDE_BUILD = %SIDE_BUILD%
IF DEFINED QTC_VERSION ECHO QTC_VERSION = %QTC_VERSION%
IF DEFINED GIT_TAG ECHO GIT_TAG = %GIT_TAG%
SET INSTALL_ROOT=
SET QMAKESPEC=
SET CDB_PATH=
SET SIDE_BUILD=
SET QTC_VERSION=
SET GIT_TAG=
GOTO END
:BEGIN
Setlocal EnableDelayedExpansion
IF NOT DEFINED SIDE_BUILD (
	SET SIDE_BUILD=0
)
IF %SIDE_BUILD% == 1 (
	SET "INSTALL_ROOT=%TEMP%\QtCreator64"
) ELSE (
	SET "INSTALL_ROOT=%BUILDROOT%\QtCreator64"
)
IF EXIST %BUILDROOT%\QtCreator RD /S /Q %BUILDROOT%\QtCreator
CALL %SCRIPTROOT%\virgin.bat backup
SET CWD=%CD%
CALL "C:\Program Files (x86)\Microsoft Visual Studio 12.0\VC\bin\x86_amd64\vcvarsx86_amd64.bat
SET "PATH=%BUILDROOT%\Qt\Qt5_x64_full\bin;C:\_\Python27;C:\Program Files\7-Zip;%BUILDROOT%\jom;%BUILDROOT%\icu\icu64\bin64;C:\_\ruby\bin;%PATH%"
SET "CDB_PATH=C:\Program Files (x86)\Windows Kits\8.1\Debuggers"
IF EXIST %SOURCEROOT%\QtCreator RD /S /Q %SOURCEROOT%\QtCreator
MD %SOURCEROOT%\QtCreator
CD %SOURCEROOT%\QtCreator
XCOPY /E /Y /Q /I /H D:\Users\Nick\Documents\GitHub\QtCreator %SOURCEROOT%\QtCreator\
sed -ie "s/\(imports = \[.Qt.\), .QtWebKit.\(\]\)/\1\2/" .\scripts\deployqt.py
FOR /F "delims=" %%X IN ('findstr /R "^QTCREATOR_VERSION" .\qtcreator.pri ^| sed -e "s/^.* = \(.*\)/\1/"') DO @SET QTC_VERSION=%%X
FOR /F "delims=" %%X IN ('git describe --long') DO @SET GIT_TAG=%%X
MD qtcb
CD qtcb
qmake -config release -r ../qtcreator.pro "CONFIG += warn_off mmx sse sse2 ltcg" "CONFIG -= 3dnow"
IF ERRORLEVEL 1 GOTO FAIL
jom -j8
IF ERRORLEVEL 1 GOTO FAIL
jom -j1 docs
IF ERRORLEVEL 1 GOTO FAIL
jom -j1 deployqt
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
CALL "C:\Program Files (x86)\Microsoft Visual Studio 12.0\VC\bin\vcvars32.bat"
SET "PATH=%BUILDROOT%\Qt\Qt5_x64_full\bin;%BUILDROOT%\Python27;C:\Program Files\7-Zip;%BUILDROOT%\jom;%BUILDROOT%\icu\icu64\bin64;%BUILDROOT%\ruby\bin;%PATH%"
SET "CDB_PATH=C:\Program Files (x86)\Windows Kits\8.1\Debuggers"
:: Prepare 32-bit mkspecs
IF EXIST %SOURCEROOT%\qtbase RD /S /Q %SOURCEROOT%\qtbase
"C:\Program Files\7-Zip\7z.exe" x -o%SOURCEROOT% %ARCHIVES%\QT-5.5.0.7z qtbase\mkspecs
SET "QMAKESPEC=%SOURCEROOT%\qtbase\mkspecs\win32-msvc2013"
qmake -config release -r ../qtcreator.pro "CONFIG += warn_off msvc_mp ltcg mmx sse sse2" "CONFIG -= 3dnow"
IF ERRORLEVEL 1 GOTO FAIL
CD .\src\libs\qtcreatorcdbext
:: Only building i686 cdb helper
jom -j8
IF ERRORLEVEL 1 GOTO FAIL
jom -j1 install
IF ERRORLEVEL 1 GOTO FAIL
:: Copy SSL libs
XCOPY /Y /Q %BUILDROOT%\OpenSSL\OpenSSL64\bin\*.dll %INSTALL_ROOT%\bin\
:: Copy whatever 'nmake bindist' forgot to copy
XCOPY /E /Y /Q /I %BUILDROOT%\Qt\Qt5_x64_full\plugins %INSTALL_ROOT%\bin\plugins\
FOR %%X IN (icudt55.dll icuin55.dll icuuc55.dll) DO (
  XCOPY /E /Y /Q /I %BUILDROOT%\icu\icu64\bin64\%%X %INSTALL_ROOT%\bin
)
:: Hack to fix qbs plugin
XCOPY /Y /Q %INSTALL_ROOT%\usr\local\bin\*.dll %INSTALL_ROOT%\bin\
COPY /Y %SOURCEROOT%\QtCreator\LICENSE.LGPLv3 %INSTALL_ROOT%\LICENSE.txt
unix2dos -ascii %INSTALL_ROOT%\LICENSE.txt
COPY /Y "%VCINSTALLDIR%\redist\x64\Microsoft.VC120.CRT\msvcp120.dll" %INSTALL_ROOT%\bin\
COPY /Y "%VCINSTALLDIR%\redist\x64\Microsoft.VC120.CRT\msvcr120.dll" %INSTALL_ROOT%\bin\
:: Purge .lib files
FOR /R %INSTALL_ROOT% %%X IN (*.lib) DO DEL /Q %%X
IF ERRORLEVEL 1 GOTO FAIL
SET "QTC_STRING=QtCreator-%QTC_VERSION%_%GIT_TAG%"
ECHO Creating installer...
ECHO Installer log: %PACKAGEDIR%\%QTC_STRING%-x64-setup.log
IF EXIST "%PACKAGEDIR%\%QTC_STRING%-x64-setup.exe" DEL /Q "%PACKAGEDIR%\%QTC_STRING%-x64-setup.exe"
"C:\Program Files (x86)\Inno Setup 5\ISCC.exe" "/dMyFilesRoot=%INSTALL_ROOT%" "/dPACKDIR=%PACKAGEDIR%" "/dMyAppVersion=%QTC_VERSION%" "/dMyIcon=%SOURCEROOT%\QtCreator\src\app\qtcreator.ico" "/f%QTC_STRING%-x64-setup" "/o%PACKAGEDIR%" "%SCRIPTROOT%\QtCreator\qtc64.iss" > %PACKAGEDIR%\%QTC_STRING%-x64-setup.log
GOTO CLEANUP
:END
CALL %SCRIPTROOT%\virgin.bat restore