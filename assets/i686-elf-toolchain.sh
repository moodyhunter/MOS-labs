#!/bin/bash

export PREFIX="/tmp"           # <--- CHANGE THIS
export MAKEFLAGS="-j$(nproc)"  # Change this to your liking
export BINUTILS_VERSION="2.40" # The latest version at the time of writing
export GCC_VERSION="13.1.0"    # The latest version at the time of writing
export GDB_VERSION="13.1"      # The latest version at the time of writing
export TARGET="i686-elf"       # The target triple

# exit on error
set -e

echo "Compiling $TARGET toolchain..."
echo "This will take a LONG TIME. Go grab a coffee or something."
echo "The logs will be saved to $PREFIX/_work, and the binaries will be installed to $PREFIX/bin."

mkdir "$PREFIX"
cd "$PREFIX"
mkdir _work && cd _work

# Download and compile binutils
wget https://ftp.gnu.org/gnu/binutils/binutils-$BINUTILS_VERSION.tar.gz
tar -xf binutils-$BINUTILS_VERSION.tar.gz

cd binutils-$BINUTILS_VERSION
mkdir build && cd build

echo "Configuring binutils..."
../configure \
    --target="$TARGET" \
    --prefix="$PREFIX" \
    --disable-nls \
    --disable-werror >binutils_configure.log

echo "Compiling binutils..."
make && make install >binutils_make.log
cd ../..

# Download and compile GCC
wget https://ftp.gnu.org/gnu/gcc/gcc-$GCC_VERSION/gcc-$GCC_VERSION.tar.gz
tar -xf gcc-$GCC_VERSION.tar.gz

cd gcc-$GCC_VERSION
mkdir build && cd build

echo "Configuring GCC..."
../configure \
    --target="$TARGET" \
    --prefix="$PREFIX" \
    --disable-nls \
    --disable-werror \
    --without-headers \
    --enable-libgcc \
    --enable-languages=c,c++ \
    --disable-build-format-warnings >gcc_configure.log

# This will take a **long** time
echo "Compiling GCC... This will take a LONG TIME."
make all-gcc all-target-libgcc >gcc_make.log
make install-gcc install-target-libgcc >gcc_install.log
cd ../..

# Download and compile GDB
wget https://ftp.gnu.org/gnu/gdb/gdb-$GDB_VERSION.tar.gz
tar -xf gdb-$GDB_VERSION.tar.gz

cd gdb-$GDB_VERSION
mkdir build && cd build

echo "Configuring GDB..."
../configure \
    --target="$TARGET" \
    --prefix="$PREFIX" \
    --program-prefix="$TARGET-" >gdb_configure.log

echo "Compiling GDB..."
make && make install >gdb_make.log
cd ../..
cd .. # back to $PREFIX
