@ECHO OFF
IF NOT EXIST %BUILDROOT%\Zlib MD %BUILDROOT%\Zlib
SET "INST_DIR=%BUILDROOT%\Zlib\Zlib"
IF EXIST %INST_DIR% RD /S /Q %INST_DIR%
CALL ..\virgin.bat backup
SET CWD=%CD%
CALL "C:\Program Files (x86)\Microsoft Visual Studio 11.0\VC\bin\vcvars32.bat"
IF EXIST ..\..\sources\Zlib RD /S /Q ..\..\sources\Zlib
MD ..\..\sources\Zlib
CD ..\..\sources\Zlib
"C:\Program Files\7-Zip\7z.exe" x T:\_compressed_sources\zlib-1.2.7.7z
MD build
CD build
cmake -D BUILD_SHARED_LIBS:BOOL=OFF -D CMAKE_INSTALL_PREFIX:STRING="T:/_outdir/Zlib/Zlib" -D CMAKE_BUILD_TYPE:STRING="None" -D CMAKE_VERBOSE_MAKEFILE:BOOL=OFF -D CMAKE_C_FLAGS:STRING="/MD /D NDEBUG /D UNICODE /D _UNICODE /O2 /arch:SSE /EHs-c- /GL /Gy /GR- /Y- /MP" -D CMAKE_EXE_LINKER_FLAGS:STRING="/NOLOGO /LTCG /OPT:REF /OPT:ICF=5" -D CMAKE_MODULE_LINKER_FLAGS:STRING="/NOLOGO /LTCG /OPT:REF /OPT:ICF=5" -D CMAKE_SHARED_LINKER_FLAGS:STRING="/NOLOGO /LTCG /OPT:REF /OPT:ICF=5" -G "NMake Makefiles" --build .\ ..\
sed -i -e "/^.*link\.exe/s|\(.*\)|\1 /NOLOGO /LTCG|" .\CMakeFiles\zlibstatic.dir\build.make
nmake zlib
nmake install
CD ..\..\
RD /S /Q Zlib
SET INST_DIR=
CD %CWD%
CALL ..\virgin.bat restore