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

PREFIX="$1"
if [ -z "$PREFIX" ]; then
    echo $0 dest
    exit 1
fi

cp -arLv "wrappers/i686-w64-windows-gnu.cfg" "${PREFIX}/bin/"
cp -arLv "wrappers/x86_64-w64-windows-gnu.cfg" "${PREFIX}/bin/"
cp -arLv "wrappers/clang-target-wrapper.sh" "${PREFIX}/bin/"
cp -arLv "wrappers/ld-wrapper.sh" "${PREFIX}/bin/"
cp -arLv "wrappers/objdump-wrapper.sh" "${PREFIX}/bin/"

cd "${PREFIX}/bin"
ln -sv clang-scan-deps i686-w64-mingw32-clang-scan-deps
ln -sv clang-scan-deps x86_64-w64-mingw32-clang-scan-deps
ln -sv clang-target-wrapper.sh i686-w64-mingw32-as
ln -sv clang-target-wrapper.sh i686-w64-mingw32-c++
ln -sv clang-target-wrapper.sh i686-w64-mingw32-clang
ln -sv clang-target-wrapper.sh i686-w64-mingw32-clang++
ln -sv clang-target-wrapper.sh i686-w64-mingw32-g++
ln -sv clang-target-wrapper.sh i686-w64-mingw32-gcc
ln -sv clang-target-wrapper.sh x86_64-w64-mingw32-as
ln -sv clang-target-wrapper.sh x86_64-w64-mingw32-c++
ln -sv clang-target-wrapper.sh x86_64-w64-mingw32-clang
ln -sv clang-target-wrapper.sh x86_64-w64-mingw32-clang++
ln -sv clang-target-wrapper.sh x86_64-w64-mingw32-g++
ln -sv clang-target-wrapper.sh x86_64-w64-mingw32-gcc
ln -sv ld-wrapper.sh i686-w64-mingw32-ld
ln -sv ld-wrapper.sh x86_64-w64-mingw32-ld
ln -sv llvm-addr2line i686-w64-mingw32-addr2line
ln -sv llvm-addr2line x86_64-w64-mingw32-addr2line
ln -sv llvm-ar i686-w64-mingw32-ar
ln -sv llvm-ar i686-w64-mingw32-llvm-ar
ln -sv llvm-ar x86_64-w64-mingw32-ar
ln -sv llvm-ar x86_64-w64-mingw32-llvm-ar
ln -sv llvm-dlltool i686-w64-mingw32-dlltool
ln -sv llvm-dlltool x86_64-w64-mingw32-dlltool
ln -sv llvm-nm i686-w64-mingw32-nm
ln -sv llvm-nm x86_64-w64-mingw32-nm
ln -sv llvm-objcopy i686-w64-mingw32-objcopy
ln -sv llvm-objcopy x86_64-w64-mingw32-objcopy
ln -sv llvm-ranlib i686-w64-mingw32-llvm-ranlib
ln -sv llvm-ranlib i686-w64-mingw32-ranlib
ln -sv llvm-ranlib x86_64-w64-mingw32-llvm-ranlib
ln -sv llvm-ranlib x86_64-w64-mingw32-ranlib
ln -sv llvm-readelf i686-w64-mingw32-readelf
ln -sv llvm-readelf x86_64-w64-mingw32-readelf
ln -sv llvm-size i686-w64-mingw32-size
ln -sv llvm-size x86_64-w64-mingw32-size
ln -sv llvm-strings i686-w64-mingw32-strings
ln -sv llvm-strings x86_64-w64-mingw32-strings
ln -sv llvm-strip i686-w64-mingw32-strip
ln -sv llvm-strip x86_64-w64-mingw32-strip
ln -sv llvm-windres i686-w64-mingw32-windres
ln -sv llvm-windres x86_64-w64-mingw32-windres
ln -sv objdump-wrapper.sh i686-w64-mingw32-objdump
ln -sv objdump-wrapper.sh x86_64-w64-mingw32-objdump
