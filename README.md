# Native OSX GNAT Programming Studio

## Overview

This repository contains scripts and patches for compiling the [GNAT Programming Studio][1]
against gtk-quartz, the native GTK backend for OSX. The resulting GPS binary will not
require X11 anymore, but will run as normal OSX application instead.

*Important:* gtk-quartz is considered experimental and you should not expect the resulting GPS
binary to be stable. It also is in no way supported by [AdaCore][2]. Be aware of this before
you decide to use it for any serious software development.

## Prerequisites

In order to be able to build GPS on your system, you need to have:

### GNAT GPL 2013

Just download the darwin binary from [AdaCore's libre site][3] and execute the install script.

### GTK-Quartz Toolchain

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
    jhbuild build meta-gtk-osx-bootstrap
    jhbuild build meta-gtk-osx-core

### GPS Sources

Download the following source packages from [AdaCore's libre site][3]:

 * xmlada-for-gps-5.2.1-src.tgz
 * gtkada-for-gps-5.2.1-src.tgz
 * gps-5.2.1-1-src.tgz

Double-click to untar and move the resulting folders to the root directory of your clone of
this repository. You should now have the following folders here:

 * gps-release-ide-5.2.1-src
 * gtkada-2.24.3-src
 * xmlada-4.4w-src

## Building GPS

Once you have everything ready, do:

    ./patch-and-build.sh

This will patch the GPS sources and afterwards use `jhbuild` (GNOME build utility) to build GPS.
The patches to gps are mostly cosmetic; compilation is configured to break on style errors and
warnings, and there are some of these in the released GPS sources, so we need to fix them
before compiling.

If you compile a second time, you don't need to patch the sources again. Simply do:

    jhbuild shell < build-gps.sh

The compilation process will patch the generated file `gnatlib/gnatcoll_shared.gpr` to get rid
of the linker option `-u _PyMac_Error`. I don't really know how that gets there and what it does, but
it breaks the build.

## Running GPS

After successfully compiling GPS, there's one more thing you need to do:

    jhbuild shell < setup-gps-environment.sh

This creates symlinks to the system's Python framework named:

 * `~/gtk/inst/lib/python2.7/config`
 * `~/gtk/inst/include/python2.7`

I have no idea why they are seached in this place, but creating those symlinks enables GPS to run.
You can now execute:

    ./run-gps.sh

## Known issues

 * Fonts are quite small in the editor and project view. But you can change these in GPS' preferences.
 * You can use `[Command]+C / +V / +X`, but other shortcuts will still require `[Ctrl]` instead. You cannot
   set them to `[Command]+[Key]` in the key bindings editor, as `[Command]` isn't recognized as a modifier
   key there.
 * Currently, pyObject and pyGtk are not supported. You will get some error messages because of this.
   This may or may not be easy to fix in the GPS build script - I didn't try yet.
 * This list is not complete and will probably be grow as I use my native GPS.

## What else can be done

If we can get rid of those pesty Python problems, it might be possible to merge everything into a
redistributable app bundle, using [gtk-mac-bundler][6]. I'm not sure whether this is doable without
an unreasonable amount of work.

To provide any more integration into OSX, GtkOSXApplication would need to be added to GtkAda, and
GPS would need to be patched to use it. I certainly won't do this, but if anyone has a lot of time
at hand...

It might also be possible to create a jhbuild module to further automate the process of building
GPS. But as the build needs a compiler jhbuild does not know about and considering the other issues
and fixes that need to be applied, I think it's better to keep this stuff here in a separate
repository.

## License

The GNAT Programming Studio is distributed under the terms of the GNU GPL, so are these scripts and
patches.



 [1]: http://libre.adacore.com/tools/gps/
 [2]: http://www.adacore.com/
 [3]: http://libre.adacore.com/i
 [4]: https://live.gnome.org/GTK%2B/OSX/Building
 [5]: http://git.gnome.org/browse/gtk-osx/plain/gtk-osx-build-setup.sh
 [6]: https://live.gnome.org/GTK%2B/OSX/Bundling
