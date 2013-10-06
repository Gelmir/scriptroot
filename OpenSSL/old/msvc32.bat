@ECHO OFF
IF NOT EXIST %BUILDROOT%\OpenSSL MD %BUILDROOT%\OpenSSL
SET "INST_DIR=%BUILDROOT%\OpenSSL\OpenSSL"
IF EXIST %INST_DIR% RD /S /Q %INST_DIR%
CALL %SCRIPTROOT%\virgin.bat backup
SET CWD=%CD%
CALL "C:\Program Files (x86)\Microsoft Visual Studio 11.0\VC\bin\vcvars32.bat"
IF EXIST %SOURCEROOT%\OpenSSL RD /S /Q %SOURCEROOT%\OpenSSL
MD %SOURCEROOT%\OpenSSL
CD %SOURCEROOT%\OpenSSL
"C:\Program Files\7-Zip\7z.exe" x T:\_compressed_sources\OpenSSL-1.0.1c.7z
SET "CFLAGS=/O2 /arch:SSE /GL /Y- /MP"
SET "LDFLAGS=/NOLOGO /LTCG /OPT:REF /OPT:ICF=5 /subsystem:console"
SET "MLFLAGS=/NOLOGO /LTCG /OPT:REF /OPT:ICF=5 /subsystem:console /DLL"
SET "ASFLAGS=nasm -f win32 -Ox"
SET "PATH=%PATH%;T:\NASM"
perl Configure VC-WIN32 threads shared zlib no-sse2 -I%BUILDROOT%\Zlib\Zlib\include -L%BUILDROOT%\Zlib\Zlib\lib --prefix=%INST_DIR%
CALL .\ms\do_nasm.bat
:: MOTHER OF GOD, NOT THIS SHIT AGAIN
FOR /f "delims=" %%A IN ('findstr "^CFLAG\=" .\ms\ntdll.mak ^| sed -e "s:^CFLAG=::" -e "s:\/O[12x] ::g" -e "s:\/arch\:[-A-Z0-9]* ::g" -e "s:\/favor\:[-A-Z0-9]* ::g" -e "s:\/GL ::g" -e "s:\/Y- ::g" -e "s:\/MP- ::g"') DO @SET FLAGS1=%%A
sed -i -e "/^CFLAG/s|=.*|=%CFLAGS% %FLAGS1%|" -e "/^LFLAGS/s|=.*|=%LDFLAGS%|" -e "/^MLFLAGS/s|=.*|= %MLFLAGS%|" -e "/^ASM/s|=.*|= %ASFLAGS%|" -e "/^[[:space:]]\+\$(SHLIB_EX_OBJ) \$(CRYPTOOBJ) /s| zlib1.lib\(.*\)| zlibstatic.lib \1|" .\ms\ntdll.mak
nmake -f .\ms\ntdll.mak
nmake -f .\ms\ntdll.mak test
nmake -f .\ms\ntdll.mak install
CD ..
RD /S /Q OpenSSL
SET CFLAGS=
SET LDFLAGS=
SET MLFLAGS=
SET ASFLAGS=
SET INST_DIR=
CD %CWD%
CALL %SCRIPTROOT%\virgin.bat restore