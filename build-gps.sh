export GPR_PROJECT_PATH=$PREFIX/lib/gnat
export PATH=$PREFIX/bin:$PATH
# gnat gcc does not support -arch
export LDFLAGS=`echo $LDFLAGS | sed 's/ -arch [^ ]*//'`

cd gps-release-ide-5.2.1-src
./configure --prefix=$PREFIX --with-python=$PREFIX/bin/python
patch gnatlib/gnatcoll_shared.gpr < ../gnatcoll_shared.gpr.patch
# PYTHON is taken as external input value to gnatlib/gnatcoll_shared, but in
# the jhbuild environment, it's set to the current python executable path.
export PYTHON=yes
make && make install
