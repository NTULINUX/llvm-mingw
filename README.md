LLVM MinGW (minimal)
==========

This is a recipe for reproducibly building a
[LLVM](https://llvm.org)/[Clang](https://clang.llvm.org/)/[LLD](https://lld.llvm.org/)
based mingw-w64 toolchain.

Heavily modified and trimmed down by Alec Ari.

Main changes include:

 - Remove Docker
 - Remove CI/CD
 - Remove tests
 - Remove many features such as CFI and sanitizers (this list is very long)
 - Bump MinGW target to 0X0AA (Windows 10 instead of 7)
 - Build everything with LLVM toolchain instead of GCC (This requires Clang)
 - Simplify all Bash scripts and remove pretty much everything else (ARM, Mac support, etc.)
   This does remove a lot of flexibility, support, and control but should also help
   avoid a few bugs. This is a very minimalistic LLVM MinGW toolchain and should
   only be used if you know you do not need any additional features. I am personally
   using this to simply compile Wine and DXVK.

TODO:

 - Attempt to build an entirely static LLVM toolchain for better portability
   across Linux systems. This allows us to distribute binaries in tarballs better.
 - Re-work git

Developer Note:

 - `-DLLVM_BUILD_STATIC=ON`
 - `-DBUILD_SHARED_LIBS=OFF`
 - `-DLIBOMP_ENABLE_SHARED=OFF`
