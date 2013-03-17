#!/bin/bash
G_BUILDROOT="/t/_outdir"
G_SCRIPTROOT="/t/scripts"
G_SOURCEROOT="/t/sources"
MY_DIR=`pwd`

if [ -d "${G_SOURCEROOT}/Zlib" ]
then
    rm -fr "${G_SOURCEROOT}/Zlib"
fi
mkdir -v "${G_SOURCEROOT}/Zlib"
cd "${G_SOURCEROOT}/Zlib"
    
INST_DIR="${G_BUILDROOT}/Zlib/Zlibd_G"
if [ -d "${INST_DIR}" ]
then
    rm -fr "${INST_DIR}"
fi
mkdir -pv "${INST_DIR}"

"/c/Program Files/7-Zip/7z.exe" x /t/_compressed_sources/zlib-1.2.7.7z -o"${G_SOURCEROOT}"/Zlib

# Editing CFLAGS
sed -i -e "s/\(CFLAGS = \$(LOC) \)-O3\( -Wall\)/\1\2 -march=i686 -mmmx -msse -msse2 -pipe -fstack-protector-all -fno-exceptions -O0 -g -fno-omit-frame-pointer/" -e "s/\(ASFLAGS = \).*/\1\$(CFLAGS)/" -e "s/\(LDFLAGS = \$(LOC)\)/\1 -fstack-protector-all -Wl,-O1 -Wl,--as-needed -Wl,--nxcompat -Wl,--dynamicbase/" ./win32/Makefile.gcc
make LOC="-DDEBUG -DDEBUG" -fwin32/Makefile.gcc
make test -fwin32/Makefile.gcc
make install -fwin32/Makefile.gcc SHARED_MODE=0 DESTDIR="${INST_DIR}/" INCLUDE_PATH="include" LIBRARY_PATH="lib" BINARY_PATH="bin"
cd "${MY_DIR}"
rm -fr "${G_SOURCEROOT}/Zlib"