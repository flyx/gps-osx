#!/bin/sh

export ADA_PROJECT_PATH=$PREFIX/lib/gnat
export PATH=$PREFIX/bin:$PATH
# gnat gcc does not support -arch
export LDFLAGS=`echo $LDFLAGS | sed 's/ -arch [^ ]*//'`

cd xmlada-4.4w-src
./configure --prefix=$PREFIX
make && make install
cd ../gtkada-2.24.3-src
./configure --prefix=$PREFIX
make && make install
cd ../gps-release-ide-5.2.1-src
./configure --prefix=$PREFIX --with-python=$PREFIX/bin/python
patch gnatlib/gnatcoll_shared.gpr < ../gnatcoll_shared.gpr.patch
# PYTHON is taken as input value to gnatlib/gnatcoll_shared but is currently
# defined as path to our python binary, so we need to fix that
export PYTHON=yes
make && make install
