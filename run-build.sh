#!/usr/bin/env bash

# set -x

INSTALL_DIR=${INSTALL_DIR:-$HOME/.local}

while [ $# -gt 0 ]; do
  case "$1" in
    --prefix)
      INSTALL_DIR="$2"
      shift
      ;;
    *)
      echo "Invalid option: $1"
      ;;
  esac
  shift
done

cmake -S llvm -B build -G Ninja                                     \
  -DCMAKE_INSTALL_PREFIX="$INSTALL_DIR"                             \
  -DCMAKE_CXX_COMPILER_LAUNCHER="ccache"                            \
  -DLLVM_LIBDIR_SUFFIX="64"                                         \
  -DLLVM_TARGETS_TO_BUILD="host"                                    \
  -DLLVM_BUILD_LLVM_DYLIB="ON"                                      \
  -DBUILD_SHARED_LIBS="ON"                                          \
  -DLLVM_USE_LINKER="gold"                                          \
  -DLLVM_ENABLE_PROJECTS="clang;clang-tools-extra;lld"              \
  -DLLVM_ENABLE_RUNTIMES="libcxx;libcxxabi;libunwind"               \
  -DLLVM_PARALLEL_COMPILE_JOBS="1"                                  \
  -DLLVM_PARALLEL_LINK_JOBS="1"

build_runtimes() {
    ninja -C build runtimes
    ninja -C build check-runtimes
    ninja -C build install-runtimes
    ninja -C build install
}

echo "Want to run 'Runtimes build'? [Y/n]"
read -r opt
case $opt in
  y*|Y*|"")
    build_runtimes
    ;;
  n*|N*)
    exit 0
    ;;
  *)
    echo "Invalid choice"
    ;;
esac
