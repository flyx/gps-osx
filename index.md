---
layout: default
title: Home
weight: 0
---

### GPS-OSX

**GPS-OSX** is a modified version the [GNAT Programming Studio][1] for OSX. Compared to the
version provided by [AdaCore][2] with GNAT GPL 2013, it provides the following enhancements:

 * It is built against gtk-quartz and thus does not need an X11 server to run.
 * You can use the command key `⌘` as modifier for keyboard shortcuts. Because of this, its
   configuration will be incompatible with AdaCore's gps and will therefore be placed in
   `~/.gps-osx` instead of `~/.gps` so that the two versions don't interfere with each other.
 * It comes as an app bundle which can simply be dropped into your `/Applications` folder.

### Very important - please read before downloading

 * gtk-quartz is considered experimental and you should not expect this binary to be stable.
   It also is in no way supported by [AdaCore][2]. Be aware of this before you decide to use
   it for any serious software development.
 * In order to take advantage of the command key, you need to change the default keyboard
   shortcuts - those have not been migrated to use command instead of control automatically.

### Download

I host a readily compiled app bundle on my server:

[Download!][4]

This is built on the base of commit [1ed91852a52af3c27ed99bc868280ea2e996a572][3].

Please note that I do not plan to create *stable* releases. I just spread the latest binary
I use myself here.

### Configuration

To be able to use your GNAT compiler, you have to tell GPS where it's located. You can do this by opening the app bundle (right click -> show package contents) and opening the file `Contents/Info.plist` (you can either edit this with the visual editor that comes with Xcode or edit it as XML with your favorite text editor). In the section *Environment variables*, there are two variables that can be edited:

 * `GNAT_HOME` is the base directory where your GNAT is installed. By default, this is `/usr/local/gnat`.
 * `ADA_PROJECT_PATH` is important when you're using third-party GPRBuild libraries. You can give a list of paths seperated by `:` here. These paths are searched for GPRBuild project files. If left empty, this variable will default to `$GNAT_HOME/lib/gnat`.

### Known issues

 * Fonts are quite small in the editor and project view. But you can change these in GPS' preferences.
 * The autocomplete list is not rendered below the cursor, but quite some pixels off.
 * GPS does not use the standard OSX menu bar. To be able to do this, one would need to patch
   GtkAda to provide the necessary binding to GtkOSXApplication and then patch GPS to use it. This
   doesn't seem worth the effort.
 * This list is not complete and will probably be grow as I use my native GPS.

### License

GPS-OSX is available under the terms of the GNU General Public License, v3.

 [1]: http://libre.adacore.com/tools/gps/
 [2]: http://www.adacore.com/
 [3]: https://github.com/flyx86/gps-osx/commit/1ed91852a52af3c27ed99bc868280ea2e996a572
 [4]: http://flyx.org/files/GPS-1ed9185.dmg