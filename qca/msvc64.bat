@ECHO OFF
GOTO BEGIN
:CLEANUP
CD %CWD%
SET INST_DIR=
IF EXIST %SOURCEROOT%\qca RD /S /Q %SOURCEROOT%\qca
GOTO END
:FAIL
ECHO Building failed, leaving source tree as is and dumping custom env vars
CD %CWD%
IF DEFINED INST_DIR ECHO INST_DIR = %INST_DIR%
SET INST_DIR=
GOTO END
:BEGIN
IF NOT EXIST %BUILDROOT%\qca64 MD %BUILDROOT%\qca64
SET "INST_DIR=%BUILDROOT%\qca64"
IF EXIST %INST_DIR% RD /S /Q %INST_DIR%
CALL %SCRIPTROOT%\virgin.bat backup
SET CWD=%CD%
CALL "C:\Program Files (x86)\Microsoft Visual Studio 11.0\VC\bin\x86_amd64\vcvarsx86_amd64.bat"
IF EXIST %SOURCEROOT%\qca RD /S /Q %SOURCEROOT%\qca
MD %SOURCEROOT%\qca
CD %SOURCEROOT%\qca
XCOPY /E /Y /Q /I C:\Users\Dayman\Documents\GitHub\qca %SOURCEROOT%\qca\
MD build
CD build
:: Also build OSSL plugin
SET "PATH=%BUILDROOT%\Qt\Qt4_x64_full\bin;%BUILDROOT%\OpenSSL\OpenSSL64\bin;%BUILDROOT%\jom;%PATH%"
SET "INCLUDE=%BUILDROOT%\OpenSSL\OpenSSL64\include;%INCLUDE%"
SET "LIB=%BUILDROOT%\OpenSSL\OpenSSL64\lib;%LIB%"
cmake -D CMAKE_INSTALL_PREFIX:STRING="C:/_/_outdir/qca64" -D QCA_INSTALL_IN_QT_PREFIX=OFF -D CMAKE_BUILD_TYPE:STRING="Release" -D CMAKE_VERBOSE_MAKEFILE:BOOL=OFF -D BUILD_TESTS:BOOL=ON -D CMAKE_CXX_FLAGS:STRING="/favor:blend /GL" -D CMAKE_EXE_LINKER_FLAGS:STRING="/INCREMENTAL:NO /NOLOGO /LTCG /OPT:REF /OPT:ICF=5" -D CMAKE_MODULE_LINKER_FLAGS:STRING="/INCREMENTAL:NO /NOLOGO /LTCG /OPT:REF /OPT:ICF=5" -D CMAKE_SHARED_LINKER_FLAGS:STRING="/INCREMENTAL:NO /NOLOGO /LTCG /OPT:REF /OPT:ICF=5" -G "NMake Makefiles JOM" --build .\ ..\
IF ERRORLEVEL 1 GOTO FAIL
jom -j4
IF ERRORLEVEL 1 GOTO FAIL
SET "PATH=%SOURCEROOT%\qca\build\src;%PATH%"
jom -j1 test
IF ERRORLEVEL 1 GOTO FAIL
jom -j1 install
IF ERRORLEVEL 1 GOTO FAIL
GOTO CLEANUP
:END
CALL %SCRIPTROOT%\virgin.bat restore