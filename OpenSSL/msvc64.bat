@ECHO OFF
GOTO BEGIN
:CLEANUP
CD %CWD%
SET INST_DIR=
SET CFLAGS=
SET LDFLAGS=
SET MLFLAGS=
SET ASFLAGS=
IF EXIST %SOURCEROOT%\OpenSSL RD /S /Q %SOURCEROOT%\OpenSSL
GOTO END
:FAIL
ECHO Building failed, leaving source tree as is and dumping custom env vars
CD %CWD%
IF DEFINED INST_DIR ECHO INST_DIR = %INST_DIR%
IF DEFINED CFLAGS ECHO CFLAGS = %CFLAGS%
IF DEFINED LDFLAGS ECHO LDFLAGS = %LDFLAGS%
IF DEFINED MLFLAGS ECHO MLFLAGS = %MLFLAGS%
IF DEFINED ASFLAGS ECHO ASFLAGS = %ASFLAGS%
SET INST_DIR=
SET CFLAGS=
SET LDFLAGS=
SET MLFLAGS=
SET ASFLAGS=
GOTO END
:BEGIN
IF NOT EXIST %BUILDROOT%\OpenSSL MD %BUILDROOT%\OpenSSL
SET "INST_DIR=%BUILDROOT%\OpenSSL\OpenSSL64"
IF EXIST %INST_DIR% RD /S /Q %INST_DIR%
CALL %SCRIPTROOT%\virgin.bat backup
SET CWD=%CD%
CALL "C:\Program Files (x86)\Microsoft Visual Studio 11.0\VC\bin\x86_amd64\vcvarsx86_amd64.bat"
IF EXIST %SOURCEROOT%\OpenSSL RD /S /Q %SOURCEROOT%\OpenSSL
MD %SOURCEROOT%\OpenSSL
CD %SOURCEROOT%\OpenSSL
"C:\Program Files\7-Zip\7z.exe" x %ARCHIVES%\OpenSSL-1.0.1f.7z -o%SOURCEROOT%\OpenSSL
SET "CFLAGS=/O2 /favor:blend /GL /Y- /MD /w"
SET "LDFLAGS=/NOLOGO /LTCG /OPT:REF /OPT:ICF=5 /subsystem:console"
SET "MLFLAGS=/NOLOGO /LTCG /OPT:REF /OPT:ICF=5 /subsystem:console /DLL"
SET "ASFLAGS=nasm -f win64 -DNEAR -Ox"
SET "PATH=C:\_\NASM;%PATH%"
perl Configure VC-WIN64A threads shared zlib enable-md2 -I%BUILDROOT%\Zlib\Zlib64\include -L%BUILDROOT%\Zlib\Zlib64\lib --prefix=%INST_DIR%
IF ERRORLEVEL 1 GOTO FAIL
CALL .\ms\do_win64a.bat
:: MOTHER OF GOD, NOT THIS SHIT AGAIN
FOR /f "delims=" %%A IN ('findstr "^CFLAG\=" .\ms\ntdll.mak ^| sed -e "s:^CFLAG=::" -e "s:[\/-]O[012xstd] ::g" -e "s:[\/-]favor\:[-A-Z0-9]* ::g" -e "s:[\/-]GL ::g" -e "s:[\/-]Y ::g" -e "s:[\/-]MP ::g" -e "s:[\/-]M[DT][dt]\? ::g" -e "s:[\/-][Ww][0-9al]* ::g"') DO @SET FLAGS1=%%A
:: ntdll.mak has CRLF EOL, do not use sed binary mode
sed -i.%SEDEXT% -e "/^CFLAG/s|=.*|=%CFLAGS% %FLAGS1%|" -e "/^LFLAGS/s|=.*|=%LDFLAGS%|" -e "/^MLFLAGS/s|=.*|= %MLFLAGS%|" -e "/^ASM/s|=.*|= %ASFLAGS%|" -e "/^[[:space:]]\+\$(SHLIB_EX_OBJ) \$(CRYPTOOBJ)  /s|zlib1\.lib \(\$.*\)|zlib\.lib \1|" -e "s/\(^APP_CFLAG= \).*/\1/" -e "s/\(^LIB_CFLAG= \).*/\1 -D_WINDLL/" .\ms\ntdll.mak
IF EXIST .\ms\ntdll.mak.%SEDEXT% DEL /Q .\ms\ntdll.mak.%SEDEXT%
nmake -f .\ms\ntdll.mak
IF ERRORLEVEL 1 GOTO FAIL
nmake -f .\ms\ntdll.mak test
IF ERRORLEVEL 1 GOTO FAIL
nmake -f .\ms\ntdll.mak install
IF ERRORLEVEL 1 GOTO FAIL
GOTO CLEANUP
:END
CALL %SCRIPTROOT%\virgin.bat restore