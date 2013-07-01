#!/bin/sh
export PATH=$PREFIX/bin:$PATH
rm -rf GPS.app
gtk-mac-bundler gps.bundle
cd GPS.app/Contents/MacOS
# ln -s ../Resources/lib lib
# ln -s ../Resources/include include
# ln -s ../Resources/share share
# ln -s ../Resources/etc etc
