# Native OSX GNAT Programming Studio

## Overview

This repository contains scripts and patches for compiling the [GNAT Programming Studio][1]
against gtk-quartz, the native GTK backend for OSX. The resulting GPS binary will not
require X11 anymore, but will run as normal OSX application instead. Additionally, a patch
is applied that allows the usage of the command key `⌘` for key shortcuts. Finally, GPS will
be packed into an app bundle that can be dropped into the `/Applications` folder.

### Very important - please read before using

 * gtk-quartz is considered experimental and you should not expect the resulting GPS
   binary to be stable. It also is in no way supported by [AdaCore][2]. Be aware of this before
   you decide to use it for any serious software development.
 * Because of support of the command key for shortcuts, this GPS binary's configuration will
   be **incompatible** with that from AdaCore's GPS. You will probably need to delete `~/.gps`
   when switching from one to the other.
 * In order to take advantage of command key shortcuts, you need to change the default key shortcuts -
   those have not been migrated to use command instead of control automatically.

### Binary download

I host a readily compiled binary on my server:

    http://flyx.org/files/GPS.dmg

Please be aware that I might remove it any time if bandwidth usage gets too high. Don't expect
it to always be up-to-date with the repository. If I have time, I might create a site that hosts
the binary and provides meta-information. Currently, this is just bleeding edge.

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
    jhbuild build meta-gtk-osx-bootstrap python meta-gtk-osx-core meta-gtk-osx-python

GPS embeds Python, so we compile python itself here (linking to the system's python causes far too
much problems) and then build meta-gtk-osx-python for pyGObject and pyGtk.

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
Two patches are being applied here:

 * `gps-remove-compile-errors.patch` is  mostly cosmetic; compilation is configured to break on
   style errors and warnings, and there are some of these in the released GPS sources, so we need
   to fix them before compiling.
 * `gps-osx-command-key-shortcuts.patch` enables the usage of the command key `⌘`, as commonly used
   in OSX, as keyboard shortcut. This patch is not really platform-specific; it would simply do the
   same thing with the meta key on linux or the Windows key on Windows - but on those systems, this
   modifier is usually not used by applications.

If you compile a second time, you don't need to patch the sources again. Simply do:

    jhbuild shell < build-gps.sh

The compilation process will patch the generated file `gnatlib/gnatcoll_shared.gpr` to get rid
of the linker option `-u _PyMac_Error`. I don't really know how that gets there and what it does, but
it breaks the build.

## Running GPS directly

If everything worked properly, you should now be able to launch gps with

    export ADA_PROJECT_PATH=~/gtk/inst/lib/gnat
    ~/gtk/inst/bin/gps

(You need the `ADA_PROJECT_PATH` if you plan to link to installed GPRBuild projects like GtkAda.)

## Building the app bundle

After building GPS, navigate into the `bundle` folder and execute

    jhbuild shell < build-bundle.sh

This should create the bundle. To be able to do this, you need to have the latest
[gtk-mac-bundler][6] from git installed (the current stable version mentioned on the site won't work).

## Known issues

 * Fonts are quite small in the editor and project view. But you can change these in GPS' preferences.
 * The autocomplete list is not rendered below the cursor, but quite some pixels off.
 * Setting the `GPR_PROJECT_PATH` does not work when double-clicking the app bundle. If you need it,
   you have to launch `GPS.app/Contents/MacOS/GPS` from the terminal. I have no idea why this is
   happening - the environment variable can be set in the Info.plist in the app bundle so that GPS is
   loaded with it, and it will be there then, but GPS won't load projects from there anyway. Maybe it's
   a sandboxing issue or something.
 * You need to have GNAT GPL 2013 installed in the default directory `/usr/local/gnat` in order to run
   GPS. This is because GNAT's `libgcc_s.1.dylib` is referenced by GPS. I didn't yet succeed in
   packing that properly into the bundle.
 * Project templates are not bundled yet and GPS will fail if you try to use them. Coming soon.
 * This list is not complete and will probably be grow as I use my native GPS.

## What else can be done

To provide more integration into OSX (= using the default OSX menu bar), GtkOSXApplication would need
to be added to GtkAda, and GPS would need to be patched to use it. I certainly won't do this, but if
anyone has a lot of time at hand...

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
