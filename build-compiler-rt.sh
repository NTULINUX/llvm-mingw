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

SRC_DIR=../lib/builtins
BUILD_SUFFIX=
BUILD_BUILTINS=TRUE

while [ $# -gt 0 ]; do
    if [ "$1" = "--native" ]; then
        NATIVE=1
        SRC_DIR=..
    else
        PREFIX="$1"
    fi
    shift
done
if [ -z "$PREFIX" ]; then
    echo "$0 [--native] dest"
    exit 1
fi

mkdir -p "$PREFIX"
PREFIX="$(cd "$PREFIX" && pwd)"
export PATH="$PREFIX/bin:$PATH"

: ${ARCHS:=${TOOLCHAIN_ARCHS-i686 x86_64}}

CLANG_RESOURCE_DIR="$("$PREFIX/bin/clang" --print-resource-dir)"

if [ ! -d llvm-project/compiler-rt ] || [ -n "$SYNC" ]; then
    CHECKOUT_ONLY=1 ./build-llvm.sh
fi

if command -v ninja >/dev/null; then
    CMAKE_GENERATOR="Ninja"
else
    : ${CORES:=$(nproc 2>/dev/null)}
    : ${CORES:=$(sysctl -n hw.ncpu 2>/dev/null)}
    : ${CORES:=4}

    case $(uname) in
    MINGW*)
        CMAKE_GENERATOR="MSYS Makefiles"
        ;;
    esac
fi

cd llvm-project/compiler-rt

INSTALL_PREFIX="$CLANG_RESOURCE_DIR"

if [ -h "$CLANG_RESOURCE_DIR/include" ]; then
    # Symlink to system headers; use a staging directory in case parts
    # of the resource dir are immutable
    WORKDIR="$(mktemp -d)"; trap "rm -rf $WORKDIR" 0
    INSTALL_PREFIX="$WORKDIR/install"
fi

if [ -n "$NATIVE" ]; then
    [ -z "$CLEAN" ] || rm -rf build-native
    mkdir -p build-native
    cd build-native
    [ -n "$NO_RECONF" ] || rm -rf CMake*
    cmake \
        ${CMAKE_GENERATOR+-G} "$CMAKE_GENERATOR" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$CLANG_RESOURCE_DIR" \
        -DCMAKE_C_COMPILER=clang \
        -DCMAKE_CXX_COMPILER=clang++ \
        -DLLVM_CONFIG_PATH="" \
        -DCMAKE_FIND_ROOT_PATH=$PREFIX \
        -DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE=ONLY \
        -DCMAKE_FIND_ROOT_PATH_MODE_PACKAGE=ONLY \
        -DCOMPILER_RT_USE_LIBCXX=OFF \
        $SRC_DIR
    cmake --build . ${CORES:+-j${CORES}}
    cmake --install . --prefix "$INSTALL_PREFIX"

    if [ "$INSTALL_PREFIX" != "$CLANG_RESOURCE_DIR" ]; then
        # symlink to system headers - skip copy
        rm -rf "$INSTALL_PREFIX/include"

        cp -r "$INSTALL_PREFIX/." $CLANG_RESOURCE_DIR
    fi
    exit 0
fi

for arch in $ARCHS; do
    [ -z "$CLEAN" ] || rm -rf build-$arch$BUILD_SUFFIX
    mkdir -p build-$arch$BUILD_SUFFIX
    cd build-$arch$BUILD_SUFFIX
    [ -n "$NO_RECONF" ] || rm -rf CMake*
    cmake \
        ${CMAKE_GENERATOR+-G} "$CMAKE_GENERATOR" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$CLANG_RESOURCE_DIR" \
        -DCMAKE_C_COMPILER=$arch-w64-mingw32-clang \
        -DCMAKE_CXX_COMPILER=$arch-w64-mingw32-clang++ \
        -DCMAKE_SYSTEM_NAME=Windows \
        -DCMAKE_AR="$PREFIX/bin/llvm-ar" \
        -DCMAKE_RANLIB="$PREFIX/bin/llvm-ranlib" \
        -DCMAKE_C_COMPILER_WORKS=1 \
        -DCMAKE_CXX_COMPILER_WORKS=1 \
        -DCMAKE_C_COMPILER_TARGET=$arch-w64-windows-gnu \
        -DCOMPILER_RT_DEFAULT_TARGET_ONLY=TRUE \
        -DCOMPILER_RT_USE_BUILTINS_LIBRARY=TRUE \
        -DCOMPILER_RT_EXCLUDE_ATOMIC_BUILTIN=FALSE \
        -DLLVM_CONFIG_PATH="" \
        -DCMAKE_FIND_ROOT_PATH=$PREFIX/$arch-w64-mingw32 \
        -DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE=ONLY \
        -DCMAKE_FIND_ROOT_PATH_MODE_PACKAGE=ONLY \
        $SRC_DIR
    cmake --build . ${CORES:+-j${CORES}}

    cmake --install . --prefix "$INSTALL_PREFIX"
    mkdir -p "$PREFIX/$arch-w64-mingw32/bin"
    cd ..
done

if [ "$INSTALL_PREFIX" != "$CLANG_RESOURCE_DIR" ]; then
    # symlink to system headers - skip copy
    rm -rf "$INSTALL_PREFIX/include"

    cp -r "$INSTALL_PREFIX/." $CLANG_RESOURCE_DIR
fi
