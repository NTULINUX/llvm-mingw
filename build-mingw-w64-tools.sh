#!/bin/sh
#
# Copyright (c) 2018 Martin Storsjo
#
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

set -ex

PREFIX="$1"
if [ -z "$CHECKOUT_ONLY" ]; then
    if [ -z "$PREFIX" ]; then
        echo $0 dest
        exit 1
    fi

    mkdir -p "$PREFIX"
    PREFIX="$(cd "$PREFIX" && pwd)"
fi

if [ ! -d mingw-w64 ] || [ -n "$SYNC" ]; then
    CHECKOUT_ONLY=1 ./build-mingw-w64.sh
fi

cd mingw-w64

MAKE=make
if command -v gmake >/dev/null; then
    MAKE=gmake
fi

: ${CORES:=$(nproc 2>/dev/null)}
: ${CORES:=$(sysctl -n hw.ncpu 2>/dev/null)}
: ${CORES:=4}
: ${ARCHS:=${TOOLCHAIN_ARCHS-i686 x86_64}}
: ${TARGET_OSES:=${TOOLCHAIN_TARGET_OSES-mingw32}}

INCLUDEDIR="$PREFIX/generic-w64-mingw32/include"
ANY_ARCH=$(echo $ARCHS | awk '{print $1}')

CONFIGFLAGS="$CONFIGFLAGS --enable-silent-rules"

cd mingw-w64-tools/gendef
rm -rf build${CROSS_NAME}
mkdir -p build${CROSS_NAME}
cd build${CROSS_NAME}
CC="clang" CXX="clang++" LD="ld.lld" ../configure --prefix="$PREFIX" $CONFIGFLAGS
$MAKE -j$CORES
$MAKE install-strip
mkdir -p "$PREFIX/share/gendef"
install -m644 ../COPYING "$PREFIX/share/gendef/COPYING.txt"
cd ../../widl
rm -rf build${CROSS_NAME}
mkdir -p build${CROSS_NAME}
cd build${CROSS_NAME}
CC="clang" CXX="clang++" LD="ld.lld" ../configure --prefix="$PREFIX" \
    --target=$ANY_ARCH-w64-mingw32 --with-widl-includedir="$INCLUDEDIR" $CONFIGFLAGS
$MAKE -j$CORES
$MAKE install-strip
mkdir -p "$PREFIX/share/widl"
install -m644 ../../../COPYING "$PREFIX/share/widl/COPYING.txt"
cd ..
cd "$PREFIX/bin"
# The build above produced $ANY_ARCH-w64-mingw32-widl, add symlinks to it
# with other prefixes.
for arch in $ARCHS; do
    for target_os in $TARGET_OSES; do
        if [ "$arch" != "$ANY_ARCH" ] || [ "$target_os" != "mingw32" ]; then
            ln -sf $ANY_ARCH-w64-mingw32-widl $arch-w64-$target_os-widl
        fi
    done
done
