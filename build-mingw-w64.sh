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

cd "mingw-w64"

export PATH="${PREFIX}/bin:${PATH}"

CORES=$(nproc)
ARCHS="i686 x86_64"

HEADER_ROOT="${PREFIX}/generic-w64-mingw32"

cd "mingw-w64-headers"
rm -rf "build"
mkdir -p "build"
cd "build"
CC="clang" CXX="clang++" LD="ld.lld" \
    ../configure --prefix="${HEADER_ROOT}" \
    --enable-idl --with-default-win32-winnt=0x0A00 --with-default-msvcrt=ucrt INSTALL="install -C"
make install
cd ../..
for arch in $ARCHS; do
    mkdir -p "${PREFIX}/${arch}-w64-mingw32"
    if [ ! -e "${PREFIX--disable-lib32 --enable-lib64}/${arch}-w64-mingw32/include" ]; then
        ln -sfn "../generic-w64-mingw32/include" "${PREFIX}/${arch}-w64-mingw32/include"
    fi
done

cd "mingw-w64-crt"
for arch in $ARCHS; do
    rm -rf "build-${arch}"
    mkdir -p "build-${arch}"
    cd "build-${arch}"
    case $arch in
    i686)
        FLAGS=("--enable-lib32" "--disable-lib64")
        ;;
    x86_64)
        FLAGS=("--disable-lib32" "--enable-lib64")
        ;;
    esac
    FLAGS+=("--with-default-msvcrt=ucrt")
    FLAGS+=("--enable-silent-rules")
    ../configure \
        --host="$arch-w64-mingw32" \
        --prefix="$PREFIX/$arch-w64-mingw32" \
        "${FLAGS[@]}"
    make -j"${CORES}"
    make install
    cd ..
done
cd ..

for arch in $ARCHS; do
    if [ ! -f "${PREFIX}/${arch}-w64-mingw32/lib/libssp.a" ]; then
        # Create empty dummy archives, to avoid failing when the compiler
        # driver adds "-lssp -lssh_nonshared" when linking.
        llvm-ar rcs "$PREFIX/${arch}-w64-mingw32/lib/libssp.a"
        llvm-ar rcs "$PREFIX/${arch}-w64-mingw32/lib/libssp_nonshared.a"
    fi

    mkdir -p "${PREFIX}/${arch}-w64-mingw32/share/mingw32"
    for file in COPYING COPYING.MinGW-w64/COPYING.MinGW-w64.txt COPYING.MinGW-w64-runtime/COPYING.MinGW-w64-runtime.txt; do
        install -m644 "${file}" "${PREFIX}/${arch}-w64-mingw32/share/mingw32"
    done
done
