#!/bin/sh
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

LLVM_BRANCH="release/22.x"

BUILDDIR="build"

if [ -n "$PREFIX" ]; then
    echo Unrecognized parameter $1
    exit 1
fi
PREFIX="$1"
if [ -z "$PREFIX" ]; then
    echo $0 dest
    exit 1
fi

if [ ! -d llvm-project ]; then
    git clone --depth=1 --single-branch -b "${LLVM_BRANCH}" https://github.com/llvm/llvm-project.git
else
    cd llvm-project
    git pull
    cd ..
fi

CMAKEFLAGS="$LLVM_CMAKEFLAGS"
CMAKEFLAGS="$CMAKEFLAGS -DCMAKE_C_COMPILER=clang"
CMAKEFLAGS="$CMAKEFLAGS -DCMAKE_CXX_COMPILER=clang++"
CMAKEFLAGS="$CMAKEFLAGS -DLLVM_USE_LINKER=lld"
CMAKEFLAGS="$CMAKEFLAGS -DLLVM_ENABLE_LTO=thin"

cd llvm-project/llvm

PROJECTS="clang;lld;polly"

rm -rf $BUILDDIR
mkdir -p $BUILDDIR
cd $BUILDDIR

rm -rf CMake*
cmake \
    -DCMAKE_GENERATOR="Ninja" \
    -DCMAKE_INSTALL_PREFIX="$PREFIX" \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_SHARED_LIBS=OFF \
    -DLLVM_BUILD_STATIC=ON \
    -DLLVM_BUILD_TESTS=OFF \
    -DLLVM_INCLUDE_TESTS=OFF \
    -DCLANG_INCLUDE_TESTS=OFF \
    -DLLVM_ENABLE_PROJECTS="$PROJECTS" \
    -DLLVM_ENABLE_BINDINGS=OFF \
    -DLLVM_TARGETS_TO_BUILD="X86" \
    -DLLVM_INSTALL_TOOLCHAIN_ONLY=ON \
    -DLLVM_TOOLCHAIN_TOOLS="llvm-ar;llvm-ranlib;llvm-objdump;llvm-rc;llvm-cvtres;llvm-nm;llvm-strings;llvm-readobj;llvm-dlltool;llvm-pdbutil;llvm-objcopy;llvm-strip;llvm-cov;llvm-profdata;llvm-addr2line;llvm-symbolizer;llvm-windres;llvm-ml;llvm-readelf;llvm-size;llvm-cxxfilt;llvm-lib" \
    $CMAKEFLAGS \
    ..

    cmake --build .
    cmake --install . --strip

    cp ../LICENSE.TXT $PREFIX
