@ECHO OFF
GOTO BEGIN
:CLEANUP
CD %CWD%
SET INST_DIR=
IF EXIST %SOURCEROOT%\Zlib RD /S /Q %SOURCEROOT%\Zlib
GOTO END
:FAIL
ECHO Building failed, leaving source tree as is and dumping custom env vars
CD %CWD%
IF DEFINED INST_DIR ECHO INST_DIR = %INST_DIR%
SET INST_DIR=
GOTO END
:BEGIN
IF NOT EXIST %BUILDROOT%\Zlib MD %BUILDROOT%\Zlib
SET "INST_DIR=%BUILDROOT%\Zlib\Zlib64"
IF EXIST %INST_DIR% RD /S /Q %INST_DIR%
MD %INST_DIR%
CALL %SCRIPTROOT%\virgin.bat backup
SET CWD=%CD%
CALL "C:\Program Files (x86)\Microsoft Visual Studio 10.0\VC\bin\amd64\vcvars64.bat"
IF EXIST %SOURCEROOT%\Zlib RD /S /Q %SOURCEROOT%\Zlib
MD %SOURCEROOT%\Zlib
CD %SOURCEROOT%\Zlib
"C:\Program Files\7-Zip\7z.exe" x T:\_compressed_sources\zlib-1.2.7.7z -o%SOURCEROOT%\Zlib
:: Time to edit Makefiles
sed -b -e "s/\(^ASFLAGS = \).*\(\$(LOC)\)/\1\2/" -e "s/\(^AS = \).*/\1ml64/" -e "s/\(^CFLAGS  = \).*\(\$(LOC)\)/\1 -nologo -MD -O2 -W3 -favor\:blend -GL -GR- -Y- -MP -EHs-c- \2/" -e "s/\(^LDFLAGS = \).*/\1-nologo -incremental\:no -opt\:ref -opt\:icf=5 -ltcg/" -e "s/\(^ARFLAGS = .*\)/\1 -ltcg/" < .\win32\Makefile.msc > .\win32\Makefile.msc.%SEDEXT%
MOVE /Y .\win32\Makefile.msc.%SEDEXT% .\win32\Makefile.msc
SET "PATH=%BUILDROOT%\jom;%PATH%"
jom -j4 -f .\win32\Makefile.msc AS=ml64 LOC="-DASMV -DASMINF -DNDEBUG -I." OBJA="inffasx64.obj gvmat64.obj inffas8664.obj"
IF ERRORLEVEL 1 GOTO FAIL
jom -j1 -f .\win32\Makefile.msc test
IF ERRORLEVEL 1 GOTO FAIL
:: Provided Makefile has no install target; doing this ourselves
XCOPY /Y /Q /I .\*.dll %INST_DIR%\bin\
XCOPY /Y /Q /I .\*.lib %INST_DIR%\lib\
XCOPY /Y /Q /I .\zconf.h %INST_DIR%\include\
XCOPY /Y /Q /I .\zlib.h %INST_DIR%\include\
GOTO CLEANUP
:END
CALL %SCRIPTROOT%\virgin.bat restore