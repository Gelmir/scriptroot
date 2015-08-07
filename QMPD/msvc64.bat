@ECHO OFF
GOTO BEGIN
:CLEANUP
IF %SIDE_BUILD% == 1 (
	IF EXIST %INST_DIR% RD /S /Q %INST_DIR%
)
CD %CWD%
SET INST_DIR=
SET SIDE_BUILD=
SET QMPD_VERSION=
SET GIT_TAG=
IF EXIST %SOURCEROOT%\qmpdclient RD /S /Q %SOURCEROOT%\qmpdclient
GOTO END
:FAIL
ECHO Building failed, leaving source tree as is and dumping custom env vars
CD %CWD%
IF DEFINED INST_DIR ECHO INST_DIR = %INST_DIR%
IF DEFINED SIDE_BUILD ECHO SIDE_BUILD = %SIDE_BUILD%
IF DEFINED QMPD_VERSION ECHO QMPD_VERSION = %QMPD_VERSION%
IF DEFINED GIT_TAG ECHO GIT_TAG = %GIT_TAG%
SET INST_DIR=
SET SIDE_BUILD=
SET QMPD_VERSION=
SET GIT_TAG=
GOTO END
:BEGIN
Setlocal EnableDelayedExpansion
IF NOT DEFINED SIDE_BUILD (
	SET SIDE_BUILD=0
)
IF %SIDE_BUILD% == 1 (
	SET "INST_DIR=%TEMP%\qmpdclient64"
) ELSE (
	SET "INST_DIR=%BUILDROOT%\qmpdclient64"
)
IF EXIST %INST_DIR% RD /S /Q %INST_DIR%
MD %INST_DIR%
CALL %SCRIPTROOT%\virgin.bat backup
SET CWD=%CD%
CALL "C:\Program Files (x86)\Microsoft Visual Studio 12.0\VC\bin\x86_amd64\vcvarsx86_amd64.bat"
IF EXIST %SOURCEROOT%\qmpdclient RD /S /Q %SOURCEROOT%\qmpdclient
MD %SOURCEROOT%\qmpdclient
CD %SOURCEROOT%\qmpdclient
XCOPY /E /Y /Q /I /H D:\Users\Nick\Documents\GitHub\qmpdclient %SOURCEROOT%\qmpdclient\
FOR /F "delims=" %%X IN ('findstr /R "^VERSION" .\qmpdclient.pro ^| sed -e "s/^.* = \(.*\)/\1/"') DO @SET QMPD_VERSION=%%X
FOR /F "delims=" %%X IN ('git describe --long') DO @SET GIT_TAG=%%X
MD build
CD build
SET "PATH=%BUILDROOT%\Qt\Qt4_x64_qbt\bin;%BUILDROOT%\jom;%PATH%"
sed -i -e "s:^\(CONFIG.*\)debug:\1:" -e "s:^\(QMAKE_LFLAGS_RELEASE.*\):#\1:" -e "s:^\(translations\.path = \):\1translations:" ..\qmpdclient.pro
IF ERRORLEVEL 1 GOTO FAIL
qmake -config release -r ../qmpdclient.pro "CONFIG += warn_off ltcg mmx sse sse2" "CONFIG -= 3dnow" "LIBS += User32.lib"
IF ERRORLEVEL 1 GOTO FAIL
jom -j4
IF ERRORLEVEL 1 GOTO FAIL
jom -j1 install
IF ERRORLEVEL 1 GOTO FAIL
COPY /Y %SOURCEROOT%\qmpdclient\build\release\qmpdclient.exe %INST_DIR%\
FOR %%X IN (QtCore4.dll QtGui4.dll QtNetwork4.dll QtXml4.dll QtXmlPatterns4.dll) DO (
    COPY /Y %BUILDROOT%\Qt\Qt4_x64_qbt\bin\%%X %INST_DIR%\
)
XCOPY /Y /Q %BUILDROOT%\OpenSSL\OpenSSL64\bin\*.dll %INST_DIR%\
XCOPY /E /Y /Q /I %BUILDROOT%\Qt\Qt4_x64_qbt\plugins %INST_DIR%\plugins\
IF NOT EXIST %INST_DIR%\translations MD %INST_DIR%\translations
XCOPY /Y /Q %SOURCEROOT%\qmpdclient\lang\*.qm %INST_DIR%\translations\
:: Copy VC++ 2013 x64 Redist DLLs
COPY /Y "%VCINSTALLDIR%\redist\x64\Microsoft.VC120.CRT\msvcp120.dll" %INST_DIR%\
COPY /Y "%VCINSTALLDIR%\redist\x64\Microsoft.VC120.CRT\msvcr120.dll" %INST_DIR%\
COPY /Y %SOURCEROOT%\qmpdclient\COPYING %INST_DIR%\LICENSE.txt
unix2dos -ascii %INST_DIR%\LICENSE.txt
echo [Paths] > %INST_DIR%\qt.conf
echo Plugins = ./plugins >> %INST_DIR%\qt.conf
SET "QMPD_STRING=qmpdclient-%QMPD_VERSION%_%GIT_TAG%"
ECHO Creating installer...
ECHO Installer log: %PACKAGEDIR%\%QMPD_STRING%-x64-setup.log
IF EXIST "%PACKAGEDIR%\%QMPD_STRING%-x64-setup.exe" DEL /Q "%PACKAGEDIR%\%QMPD_STRING%-x64-setup.exe"
"C:\Program Files (x86)\Inno Setup 5\ISCC.exe" "/dMyFilesRoot=%INST_DIR%" "/dPACKDIR=%PACKAGEDIR%" "/dMyAppVersion=%QMPD_VERSION%" "/dMyIcon=%SOURCEROOT%\qmpdclient\icons\qmpdclient.ico" "/f%QMPD_STRING%-x64-setup" "/o%PACKAGEDIR%" "%SCRIPTROOT%\QMPD\qmpd64.iss" > %PACKAGEDIR%\%QMPD_STRING%-x64-setup.log
IF ERRORLEVEL 1 GOTO FAIL
GOTO CLEANUP
:END
CALL %SCRIPTROOT%\virgin.bat restore