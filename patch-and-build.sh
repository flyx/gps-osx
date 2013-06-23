#!/bin/sh

if [ ! -d "xmlada-4.4w-src" ]; then
  echo "Please download and untar xmlada-for-gps-5.2.1-src.tgz from the GNAT GPL 2013 sources"
  echo "at http://libre.adacore.com/ - the resulting folder should be xmlada-4.4w-src, place it here."
  exit 1
fi

if [ ! -d "gtkada-2.24.3-src" ]; then
  echo "Please download and untar gtkada-for-gps-5.2.1-src.tgz from the GNAT GPL 2013 sources"
  echo "at http://libre.adacore.com/ - the resulting folder should be gtkada-2.24.3-src, place it here."
fi

if [ ! -d "gps-release-ide-5.2.1-src" ]; then
  echo "Please download and untar gps-5.2.1-1-src.tgz from the GNAT GPL 2013 sources"
  echo "at http://libre.adacore.com/ - the resulting folder should be gps-release-ide-5.2.1-src, place it here."
fi

patch -d gps-release-ide-5.2.1-src -p1 < gps.patch

jhbuild shell < build-gps.sh

echo "Finished."
