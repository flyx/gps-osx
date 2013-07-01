#!/bin/sh

rm -rf GPS.app
jhbuild shell < build-bundle.sh
mkdir dist
mv GPS.app dist
hdiutil create -ov -format UDZO -volname "GNAT Programming Studio" -fs HFS+ -srcfolder dist GPS.dmg
mv dist/GPS.app .
rmdir dist
