#!/bin/sh

GNAT_KIND=${GNAT_KIND:-GPL} 
if [ "$GNAT_KIND" != "GPL" ] && [ "$GNAT_KIND" != "FSF" ] ; then
   echo "Unsupported GNAT_KIND: $1";
   exit(-1);
fi
if [ "$GNAT_KIND" != "FSF" ] ; then
   export GNAT_HOME=/usr/local/gnat
else
   export GNAT_HOME=/opt/gcc-4.8.1
fi

export PATH=$PREFIX/bin:$PATH
rm -rf GPS.app
gtk-mac-bundler gps.bundle
