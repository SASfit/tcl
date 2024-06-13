#!/bin/sh

# abort if anything fails
set -e
# show commands
set -x

name="sasfit-tcl"
mode="$1"
arch="$(uname -m)"
plat=
conf=
case "$(uname -s)" in
    Linux)  plat=linux;  conf=unix/configure;;
    Darwin) plat=macos;  conf=macosx/configure;;
    Win32)  plat=windows;conf=win/configure;; # FIXME
esac

# path of this script
scriptdir="$(cd "$(dirname "$0")" && pwd -P)"
# output dir
outdir="$scriptdir/$name"
mkdir -p "$outdir"
# add debug symbols?
DBG_ARGS=
if [ "$mode" = "debug" ]; then
    DBG_ARGS=--enable-symbols
    mode="_$mode"
fi

sh "$conf" --prefix="$outdir" --enable-static --disable-shared --enable-64bit --with-pic $DBG_ARGS

make -j 4

make install
tar Jcf "${name}_${plat}_${arch}${mode}.tar.xz" "$name"