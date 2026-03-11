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
if [ -z "$PREFIX" ]; then
    echo "${0}" dest
    exit 1
fi

cp -arLv "wrappers/"* "${PREFIX}/bin/"

cd "${PREFIX}/bin"
for a in "i686-w64-mingw32" "x86_64-w64-mingw32"; do
    ln -sv "clang-scan-deps" "${a}-clang-scan-deps"
    ln -sv "ld-wrapper.sh" "${a}-ld"
    ln -sv "objdump-wrapper.sh" "${a}-objdump"
    for b in as c++ clang clang++ g++ gcc; do ln -sv "clang-target-wrapper.sh" "${a}-${b}"; done
    for b in ar llvm-ar; do ln -sv "llvm-ar" "${a}-${b}"; done
    for b in ranlib llvm-ranlib; do ln -sv "llvm-ranlib" "${a}-${b}"; done
    for b in addr2line dlltool nm objcopy readelf size strings strip windres; do
        ln -sv "llvm-${b}" "${a}-${b}"
    done
done
