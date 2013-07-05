export GPR_PROJECT_PATH=$PREFIX/lib/gnat
export PATH=$PREFIX/bin:$PATH
# gnat gcc does not support -arch
export LDFLAGS=`echo $LDFLAGS | sed 's/ -arch [^ ]*//'`

cd gps-release-ide-5.2.1-src
./configure --prefix=$PREFIX --with-python=$PREFIX/bin/python --enable-gpl
sed  '/Python_Libs/c \
   Python_Libs    := ("-ldl", "-Wl,-framework", "-Wl,CoreFoundation", "-lpython2.7");' gnatlib/gnatcoll_shared.gpr > gnatlib/gnatcoll_shared.gpr.patched
cp gnatlib/gnatcoll_shared.gpr.patched gnatlib/gnatcoll_shared.gpr
# because git cannot manage folders
mkdir -p gnatlib/obj gnatlib/lib spark/obj spark/lib gnat obj lib
# PYTHON is taken as external input value to gnatlib/gnatcoll_shared, but in
# the jhbuild environment, it's set to the current python executable path.
export PYTHON=yes
make && make install
