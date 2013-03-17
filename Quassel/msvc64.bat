@ECHO OFF
GOTO BEGIN
:CLEANUP
CD %CWD%
SET INST_DIR=
IF EXIST %SOURCEROOT%\Quassel RD /S /Q %SOURCEROOT%\Quassel
GOTO END
:FAIL
ECHO Building failed, leaving source tree as is and dumping custom env vars
CD %CWD%
IF DEFINED INST_DIR ECHO INST_DIR = %INST_DIR%
SET INST_DIR=
GOTO END
:BEGIN
SET "INST_DIR=%BUILDROOT%\Quassel64"
IF EXIST %INST_DIR% RD /S /Q %INST_DIR%
MD %INST_DIR%
CALL %SCRIPTROOT%\virgin.bat backup
SET CWD=%CD%
CALL "C:\Program Files (x86)\Microsoft Visual Studio 10.0\VC\bin\amd64\vcvars64.bat"
IF EXIST %SOURCEROOT%\Quassel RD /S /Q %SOURCEROOT%\Quassel
MD %SOURCEROOT%\Quassel
CD %SOURCEROOT%\Quassel
:: /H also copied hidden files (.git)
XCOPY /E /Y /Q /I /H C:\Users\Dayman\Documents\GitHub\Quassel %SOURCEROOT%\Quassel\
MD build
CD build
SET "PATH=%BUILDROOT%\Qt\Qt64\bin;%BUILDROOT%\qca64\bin;%BUILDROOT%\jom;%PATH%"
SET "LIB=%BUILDROOT%\qca64\lib;%LIB%"
SET "INCLUDE=%BUILDROOT%\qca64\include;%INCLUDE%"
cmake -D CMAKE_INSTALL_PREFIX:STRING="T:/_outdir/Quassel64/bin" -D CMAKE_BUILD_TYPE:STRING="Release" -D CMAKE_VERBOSE_MAKEFILE:BOOL=OFF -DWANT_CORE=ON -DWANT_QTCLIENT=ON -DWANT_MONO=ON -DWITH_PHONON=ON -DWITH_WEBKIT=ON -DWITH_KDE=OFF -DWITH_SYSLOG=OFF -DWITH_DBUS=OFF -DWITH_LIBINDICATE=OFF -DWITH_CRYPT=ON -DSTATIC=OFF -DLINK_EXTRA=crypt32 -D CMAKE_CXX_FLAGS:STRING="/favor:blend /GL" -D CMAKE_EXE_LINKER_FLAGS:STRING="/INCREMENTAL:NO /NOLOGO /LTCG /OPT:REF /OPT:ICF=5" -D CMAKE_MODULE_LINKER_FLAGS:STRING="/INCREMENTAL:NO /NOLOGO /LTCG /OPT:REF /OPT:ICF=5" -D CMAKE_SHARED_LINKER_FLAGS:STRING="/INCREMENTAL:NO /NOLOGO /LTCG /OPT:REF /OPT:ICF=5" -G "NMake Makefiles JOM" --build .\ ..\
IF ERRORLEVEL 1 GOTO FAIL
jom -j4
IF ERRORLEVEL 1 GOTO FAIL
jom -j1 install
IF ERRORLEVEL 1 GOTO FAIL
:: Copying leftovers
FOR %%X IN (QtCore4.dll QtGui4.dll QtNetwork4.dll QtSql4.dll QtScript4.dll QtWebKit4.dll phonon4.dll QtXml4.dll QtSvg4.dll) DO (
    COPY /Y %BUILDROOT%\Qt\Qt64\bin\%%X %INST_DIR%\bin\
)
XCOPY /Y /Q %BUILDROOT%\OpenSSL\OpenSSL64\bin\*.dll %INST_DIR%\bin\
COPY /Y %BUILDROOT%\qca64\bin\qca.dll %INST_DIR%\bin\
XCOPY /E /Y /Q /I %BUILDROOT%\qca64\certs %INST_DIR%\certs\
FOR %%X IN (codecs iconengines imageformats phonon_backend) DO (
	XCOPY /E /Y /Q /I %BUILDROOT%\Qt\Qt64\plugins\%%X %INST_DIR%\plugins\%%X\
)
XCOPY /E /Y /Q /I %BUILDROOT%\qca64\plugins\crypto %INST_DIR%\plugins\crypto\
echo [Paths] > %INST_DIR%\bin\qt.conf
echo Plugins = ../plugins >> %INST_DIR%\bin\qt.conf
GOTO CLEANUP
:END
CALL %SCRIPTROOT%\virgin.bat restore