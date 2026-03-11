#!/usr/bin/env bash
#
# Copyright (c) 2018 Martin Storsjo
# Copyright (c) 2026 Alec Ari
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

set -e

PREFIX="${1}"
if [ -z "${PREFIX}" ]; then
    echo "${0} dest"
    exit 1
fi

if [ ! -d mingw-w64 ]; then
    git clone --depth=1 https://github.com/mingw-w64/mingw-w64
else
    cd "mingw-w64"
    git pull
    cd ..
fi

cd "mingw-w64"

CORES=$(nproc)

ARCHS="i686 x86_64"
ANY_ARCH=$(echo "${ARCHS}" | awk '{print $1}')

cd "mingw-w64-tools/gendef"
rm -rf "build"
mkdir -p "build"
cd build"${CROSS_NAME}"
CC="clang" CXX="clang++" LD="ld.lld" ../configure --prefix="${PREFIX}"
make -j"${CORES}"
make install-strip
mkdir -p "${PREFIX}/share/gendef"
install -m644 "../COPYING" "${PREFIX}/share/gendef/COPYING.txt"

cd "../../widl"
rm -rf "build"
mkdir -p "build"
cd "build"
CC="clang" CXX="clang++" LD="ld.lld" ../configure --prefix="${PREFIX}" \
    --target="${ANY_ARCH}-w64-mingw32" --with-widl-includedir="${PREFIX}/generic-w64-mingw32/include" \
    --enable-silent-rules
make -j"${CORES}"
make install-strip
mkdir -p "${PREFIX}/share/widl"
install -m644 ../../../COPYING "${PREFIX}/share/widl/COPYING.txt"

cd "${PREFIX}/bin"
# The build above produced $ANY_ARCH-w64-mingw32-widl, add symlinks to it
# with other prefixes.
for arch in ${ARCHS}; do
    if [ "${arch}" != "${ANY_ARCH}" ]; then
        ln -sf "${ANY_ARCH}-w64-mingw32-widl" "${arch}-w64-mingw32-widl"
    fi
done
