#!/bin/sh

# abort if anything fails
set -e
# show commands
set -x

uname -a
for bin in make gcc clang ld ar ranlib windres; do which $bin || true; done
gcc --version

name="sasfit-tcl"
mode="$1"
[ -z "$mode" ] && mode="$BUILD_MODE" # use env var if empty
arch="$(uname -m)"
plat="$(uname -s)"
conf=
case "$(echo $plat | cut -d_ -f1)" in
    Linux)   plat=linux;  conf=unix/configure;;
    Darwin)  plat=macos;  conf=unix/configure;;
    MINGW64) plat=windows;conf=win/configure;;
esac

[ -z "$CC" ] || echo "Using CC=$CC"
[ -z "$CXX" ] || echo "Using CC=$CXX"

# path of this script
scriptdir="$(cd "$(dirname "$0")" && pwd -P)"
# output dir
outdir="$scriptdir/$name"
mkdir -p "$outdir"
# add debug symbols?
DBG_ARGS=
if [ "$mode" = "debug" ]; then
    DBG_ARGS=--enable-symbols
fi

sh "$conf" --prefix="$outdir" --enable-static --disable-shared --enable-64bit --with-pic $DBG_ARGS

make -j 4

make install
tar Jcf "${name}_${plat}_${arch}_${mode}.tar.xz" "$name"
