#!/bin/bash
G_BUILDROOT="/t/_outdir"
G_SCRIPTROOT="/t/scripts"
G_SOURCEROOT="/t/sources"
if [ -d "${G_SOURCEROOT}/OpenSSL" ]
then
    rm -fr "${G_SOURCEROOT}/OpenSSL"
fi
mkdir -v "${G_SOURCEROOT}/OpenSSL"
    
INST_DIR="${G_BUILDROOT}/OpenSSL/OpenSSL_G"
if [ -d "${INST_DIR}" ]
then
    rm -fr "${INST_DIR}"
fi
mkdir -pv "${INST_DIR}"

cd "${G_SOURCEROOT}/OpenSSL"
"/c/Program Files/7-Zip/7z.exe" x /t/_compressed_sources/OpenSSL-1.0.1e.7z -o"${G_SOURCEROOT}"/OpenSSL
# LFLAGS seem not to have any effect move -Wls to CFLAGS
# Seems to NOT use SHARED_LDFLAGS in any way - dump everyhting in CFLAGS
 _CFLAGS_="-O2 -march=i686 -mmmx -msse -msse2 -fomit-frame-pointer -fpredictive-commoning -pipe -fno-exceptions -finline-small-functions -fstack-protector-all -Wl,-O1 -Wl,--as-needed -Wl,-s -shared-libgcc -Wl,--nxcompat -Wl,--dynamicbase"
_LDFLAGS_="${_CFLAGS_}"

perl Configure mingw threads shared zlib -I"${G_BUILDROOT}/Zlib/Zlib_G/include" -L"${G_BUILDROOT}/Zlib/Zlib_G/lib" --prefix="${INST_DIR}"

CFLAG=$(grep ^CFLAG= Makefile | LC_ALL=C sed \
        -e 's:^CFLAG=::' \
        -e 's:-fomit-frame-pointer ::g' \
        -e 's:-O[0-9] ::g' \
        -e 's:-march=[-a-z0-9]* ::g' \
        -e 's:-mcpu=[-a-z0-9]* ::g' \
        -e 's:-m[a-z0-9]* ::g' \
    )

sed -i -e "/^CFLAG/s|=.*|=${CFLAG} ${_CFLAGS_}|" -e "/^SHARED_LDFLAGS=/s|\(.*\)|\1 ${_LDFLAGS_}|" ./Makefile

make depend
make build_libs

# Fix tests, when unpacking OpenSSL in windows (no links)
cd test
ALL_TESTS=`find -name "*.c" -print`
for i in $ALL_TESTS
do
    if [ "`cat $i`" == "dummytest.c" ]
    then
        sed -i -e 's/\(dummytest.c\)/\#include \"\1\"/' $i
    fi
done
cd ..
make build_tests
make test
sleep 10s
# Do not install man pages
sed -i -e "s/\(^install\: all \)install_docs \(install_sw\)/\1\2/" ./Makefile
make install
cd ..
rm -fr "${G_SOURCEROOT}/OpenSSL"