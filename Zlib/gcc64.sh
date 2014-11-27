#!/bin/bash
G_BUILDROOT="/c/_/_outdir"
G_SCRIPTROOT="/c/_/scripts"
G_SOURCEROOT="/c/_/sources"
G_ARCHIVES="/c/_/_compressed_sources"
MY_DIR=`pwd`

if [ -d "${G_SOURCEROOT}/Zlib" ]
then
    rm -fr "${G_SOURCEROOT}/Zlib"
fi
mkdir -v "${G_SOURCEROOT}/Zlib"
cd "${G_SOURCEROOT}/Zlib"
    
INST_DIR="${G_BUILDROOT}/Zlib/Zlib64_G"
if [ -d "${INST_DIR}" ]
then
    rm -fr "${INST_DIR}"
fi
mkdir -pv "${INST_DIR}"

"/c/Program Files/7-Zip/7z.exe" x "${G_ARCHIVES}/zlib-1.2.8.7z" -o"${G_SOURCEROOT}"/Zlib

# Editing CFLAGS
sed -i -e "s/\(CFLAGS = \$(LOC) \)-O3\( -Wall\)/\1\2 -mtune=generic -mmmx -msse -msse2 -pipe -fstack-protector-all -fno-exceptions -O3 -fomit-frame-pointer -fpredictive-commoning -finline-small-functions/" -e "s/\(ASFLAGS = \).*/\1\$(CFLAGS)/" -e "s/\(LDFLAGS = \$(LOC)\)/\1 -fstack-protector-all -Wl,-s -Wl,-O1 -Wl,--as-needed -Wl,--nxcompat -Wl,--dynamicbase/" ./win32/Makefile.gcc
make LOC="-DNDEBUG -D_NDEBUG" -fwin32/Makefile.gcc
make test -fwin32/Makefile.gcc
make install -fwin32/Makefile.gcc SHARED_MODE=0 DESTDIR="${INST_DIR}/" INCLUDE_PATH="include" LIBRARY_PATH="lib" BINARY_PATH="bin"
cd "${MY_DIR}"
rm -fr "${G_SOURCEROOT}/Zlib"