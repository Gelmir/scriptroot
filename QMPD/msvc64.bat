@ECHO OFF
GOTO BEGIN
:CLEANUP
CD %CWD%
SET INST_DIR=
IF EXIST %SOURCEROOT%\qmpdclient RD /S /Q %SOURCEROOT%\qmpdclient
GOTO END
:FAIL
ECHO Building failed, leaving source tree as is and dumping custom env vars
CD %CWD%
IF DEFINED INST_DIR ECHO INST_DIR = %INST_DIR%
SET INST_DIR=
GOTO END
:BEGIN
SET "INST_DIR=%BUILDROOT%\qmpdclient64"
IF EXIST %INST_DIR% RD /S /Q %INST_DIR%
MD %INST_DIR%
CALL %SCRIPTROOT%\virgin.bat backup
SET CWD=%CD%
CALL "C:\Program Files (x86)\Microsoft Visual Studio 12.0\VC\bin\x86_amd64\vcvarsx86_amd64.bat"
IF EXIST %SOURCEROOT%\qmpdclient RD /S /Q %SOURCEROOT%\qmpdclient
MD %SOURCEROOT%\qmpdclient
CD %SOURCEROOT%\qmpdclient
XCOPY /E /Y /Q /I D:\Users\Nick\Documents\GitHub\qmpdclient %SOURCEROOT%\qmpdclient\
MD build
CD build
SET "PATH=%BUILDROOT%\Qt\Qt4_x64_qbt\bin;%BUILDROOT%\jom;%PATH%"
sed -i -e "s:^\(CONFIG.*\)debug:\1:" -e "s:^\(QMAKE_LFLAGS_RELEASE.*\):#\1:" ..\qmpdclient.pro
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
echo [Paths] > %INST_DIR%\qt.conf
echo Plugins = ./plugins >> %INST_DIR%\qt.conf
GOTO CLEANUP
:END
CALL %SCRIPTROOT%\virgin.bat restore