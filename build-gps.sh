#!/bin/sh

export ADA_PROJECT_PATH=$PREFIX/lib/gnat
export PATH=$PREFIX/bin:$PATH

cd xmlada-4.4w-src
./configure --prefix=$PREFIX
make && make install
cd ../gtkada-2.24.3-src
./configure --prefix=$PREFIX
make && make install
cd ../gps-release-ide-5.2.1-src
./configure --prefix=$PREFIX --with-python=/System/Library/Frameworks/Python.framework/Versions/2.7
patch gnatlib/gnatcoll_shared.gpr < ../gnatcoll_shared.gpr.patch
make && make install
