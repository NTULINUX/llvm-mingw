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

HOST_CLANG=
LLVM_ARGS=""
MINGW_ARGS=""
HOST_ARGS=""

while [ $# -gt 0 ]; do
    case "$1" in
    --host-clang|--host-clang=*)
        HOST_CLANG=${1#--host-clang}
        HOST_CLANG=${HOST_CLANG#=}
        HOST_CLANG=${HOST_CLANG:-clang}
        ;;
    --with-default-win32-winnt=*)
        MINGW_ARGS="$MINGW_ARGS $1"
        ;;
    --host=*)
        HOST_ARGS="$HOST_ARGS $1"
        ;;
    --wipe-runtimes)
        WIPE_RUNTIMES=1
        ;;
    --clean-runtimes)
        CLEAN_RUNTIMES=1
        ;;
    --stage1)
        STAGE1=1
        LLVM_ARGS="$LLVM_ARGS --disable-lldb --disable-clang-tools-extra"
        NO_LLDB=1
        ;;
    *)
        PREFIX="$1"
        ;;
    esac
    shift
done
if [ -z "$PREFIX" ]; then
    echo "$0 [--host-clang[=clang]] [--host=triple] [--with-default-win32-winnt=0x0A00] [--wipe-runtimes] [--clean-runtimes] [--stage1] dest"
    exit 1
fi

for dep in git cmake ${HOST_CLANG}; do
    if ! command -v $dep >/dev/null; then
        echo "$dep not installed. Please install it and retry" 1>&2
        exit 1
    fi
done

./build-llvm.sh $PREFIX $LLVM_ARGS $HOST_ARGS
./strip-llvm.sh $PREFIX $HOST_ARGS
./install-wrappers.sh $PREFIX $HOST_ARGS ${HOST_CLANG:+--host-clang=$HOST_CLANG}
./build-mingw-w64-tools.sh $PREFIX $HOST_ARGS
if [ -n "$NO_RUNTIMES" ]; then
    exit 0
fi
if [ -n "$WIPE_RUNTIMES" ]; then
    # Remove the runtime code built previously.
    #
    # This roughly matches the setup as if --no-runtimes had been passed,
    # except that compiler-rt headers are left installed in lib/clang/*/include.
    rm -rf $PREFIX/*-w64-mingw32 $PREFIX/lib/clang/*/lib
fi
if [ -n "$CLEAN_RUNTIMES" ]; then
    export CLEAN=1
fi
./build-mingw-w64.sh $PREFIX $MINGW_ARGS
./build-compiler-rt.sh $PREFIX
./build-libcxx.sh $PREFIX
./build-mingw-w64-libraries.sh $PREFIX
./build-compiler-rt.sh $PREFIX
./build-openmp.sh $PREFIX
