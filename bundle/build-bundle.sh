#!/bin/sh
export PATH=$PREFIX/bin:$PATH
rm -rf GPS.app
gtk-mac-bundler gps.bundle
