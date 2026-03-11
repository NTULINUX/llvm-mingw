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

set -e

PREFIX="${1}"
if [ -z "${PREFIX}" ]; then
    echo "${0} dest"
    exit 1
fi
cd "${PREFIX}/bin"

for i in amdgpu-arch bugpoint c-index-test clang-* clangd clangd-* darwin-debug diagtool dsymutil find-all-symbols git-clang-format hmaptool ld64.lld* llc lldb-* lli llvm-* modularize nvptx-arch obj2yaml offload-arch opt pp-trace sancov sanstats scan-build scan-view split-file verify-uselistorder wasm-ld yaml2* libclang.dll *LTO.dll *Remarks.dll *.bat; do
    basename="${i}"
    case $basename in
    *.sh)
        ;;
    clang++|clang-*.*|clang-cpp)
        ;;
    clang-format|git-clang-format)
        ;;
    clangd)
        ;;
    clang-scan-deps)
        ;;
    clang-tidy)
        ;;
    clang-target-wrapper*|clang-scan-deps-wrapper*)
        ;;
    clang-*)
        suffix="${basename#*-}"
        # Test removing all numbers from the suffix; if it is empty, the suffix
        # was a plain number (as if the original name was clang-7); if it wasn't
        # empty, remove the tool.
        if [ "$(echo "${suffix}" | tr -d 0-9)" != "" ]; then
            rm -f "${i}"
        fi
        ;;
    llvm-ar|llvm-cvtres|llvm-dlltool|llvm-nm|llvm-objdump|llvm-ranlib|llvm-rc|llvm-readobj|llvm-strings|llvm-pdbutil|llvm-objcopy|llvm-strip|llvm-cov|llvm-profdata|llvm-addr2line|llvm-symbolizer|llvm-wrapper|llvm-windres|llvm-ml|llvm-readelf|llvm-size|llvm-cxxfilt|llvm-lib)
        ;;
    ld64.lld|wasm-ld)
        if [ -e "$i" ]; then
            rm "${i}"
        fi
        ;;
    lldb|lldb-server|lldb-argdumper|lldb-instr|lldb-mi|lldb-vscode|lldb-dap)
        ;;
    *)
        if [ -f "${i}" ]; then
            rm "${i}"
        elif [ -L "${i}" ] && [ ! -e "$(readlink "${i}")" ]; then
            # Remove dangling symlinks
            rm "${i}"
        fi
        ;;
    esac
done
cd ..
rm -rf libexec
cd share
cd clang
for i in *; do
    case $i in
    clang-format*)
        ;;
    *)
        rm -rf "${i}"
        ;;
    esac
done
cd ..
rm -rf opt-viewer scan-build scan-view
rm -rf man/man1/scan-build*
cd ..
cd include
rm -rf clang clang-c clang-tidy lld llvm llvm-c lldb
cd ..
cd lib
rm -f ./*.dll.a
rm -f lib*.a
for i in *.so* *.dylib* cmake; do
    case ${i} in
    liblldb*|libclang-cpp*|libLLVM*)
        ;;
    *)
        rm -rf "${i}"
        ;;
    esac
done
cd ..
