## Native GNAT Programming Studio for OSX

### Overview

This repository contains the source code of the [GNAT Programming Studio][1], modified to be
built against gtk-quartz, the native GTK backend for OSX. For a list of changes, see the
[website][7]. You can also download a binary there. This is a personal project,
I am not affiliated with [AdaCore][2].

### Prerequisites

In order to be able to build GPS on your Mac, you need to have:

#### GNAT GPL 2013

Just download the darwin binary from [AdaCore's libre site][3] and execute the install script.

#### GTK-Quartz (jhbuild) Toolchain

This will probably be tricky to set up. If you're lucky, it will work at first try, but experience
tells that usually, something's broken on the way. Anyway, follow the instructions on
[live.gnome.org][4] to build it. Here's a short version:

 * Install XCode from the AppStore, launch it, install the command line tools from the
   Preferences panel.
 * Download and execute [gtk-osx-setup.sh][5]
 * Add `~/.local/bin` to your `PATH`.
 * Execute:

<!-- ends the markdown list -->

    jhbuild bootstrap
    jhbuild build meta-gtk-osx-bootstrap python meta-gtk-osx-core meta-gtk-osx-python

GPS embeds Python, so we compile python itself here (linking to the system's python causes far
too much problems) and then build meta-gtk-osx-python for pyGObject and pyGtk.

#### Dependencies

Download the following source packages from [AdaCore's libre site][3]:

 * xmlada-for-gps-5.2.1-src.tgz
 * gtkada-for-gps-5.2.1-src.tgz

After unpacking the sources, you need to build and install them as part of your jhbuild toolchain.
To do that, start a jhbuild shell with `jhbuild shell` and execute these commands in both
directories:

    export GPR_PROJECT_PATH=$PREFIX/lib/gnat
    export PATH=$PREFIX/bin:$PATH
    export LDFLAGS=`echo $LDFLAGS | sed 's/ -arch [^ ]*//'`
    ./configure --prefix=$PREFIX
    make && make install

### Building GPS

Just do:

    jhbuild shell < build-gps.sh

This will build and install gps.

### Running GPS directly

If everything worked properly, you should be able to launch gps with

    export GPR_PROJECT_PATH=~/gtk/inst/lib/gnat
    ~/gtk/inst/bin/gps

(You need the `GPR_PROJECT_PATH` if you plan to link against installed GPRBuild
projects like GtkAda.)

### Building the app bundle

After building GPS, navigate into the `bundle` folder and execute

    jhbuild shell < build-bundle.sh

This should create the bundle. To be able to do this, you need to have the latest
[gtk-mac-bundler][6] from git installed (the current stable version mentioned on the site won't work).

### What else can be done

To provide more integration into OSX (= using the default OSX menu bar), GtkOSXApplication would need
to be added to GtkAda, and GPS would need to be patched to use it. I certainly won't do this, but if
anyone has a lot of time at hand...

It might also be possible to create a jhbuild module to further automate the process of building
GPS. But as the build needs a compiler jhbuild does not know about and considering the other issues
and fixes that need to be applied, I think it's better to keep this stuff here in a separate
repository.

### License

This work is, as the GNAT Programming Studio itself, licensed under the terms of the GNU GPL v3.


 [1]: http://libre.adacore.com/tools/gps/
 [2]: http://www.adacore.com/
 [3]: http://libre.adacore.com/
 [4]: https://live.gnome.org/GTK%2B/OSX/Building
 [5]: http://git.gnome.org/browse/gtk-osx/plain/gtk-osx-build-setup.sh
 [6]: https://live.gnome.org/GTK%2B/OSX/Bundling
 [7]: http://flyx86.github.io/gps-osx/