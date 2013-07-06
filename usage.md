---
layout: default
title: Usage
weight: 1
---

## Usage

### Configuration

To be able to use your GNAT compiler, you have to tell GPS where it is located.
You can do this by opening the app bundle (right click -> show package contents)
and opening the file `Contents/Info.plist` (you can either edit this with the
visual editor that comes with Xcode or edit it as XML with your favorite text
editor). In the section *Environment variables*, there are two variables that
can be edited:

 * `GNAT_HOME` is the base directory where your GNAT is installed. By default,
   this is `/usr/local/gnat`.
 * `ADA_PROJECT_PATH` is important when you're using third-party GPRBuild
   libraries. You can give a list of paths seperated by `:` here. These paths
   are searched for GPRBuild project files. If left empty, this variable will
   default to `$GNAT_HOME/lib/gnat`.

Be aware that OSX caches the contents of the `Info.plist` file. If you modify
it after you launched GPS once, you may need to move the GPS app bundle to
another folder (not the Desktop) and back in order to clear the cache.

If you want to use the command key `⌘` for keyboard shortcuts, you have to
change the default keyboard shortcuts. You can do that by choosing
`Edit -> Key Shortcuts` from the menu.

### Known issues

 * Fonts are quite small in the editor and project view. But you can change
   these in GPS' preferences.
 * The autocomplete list is not rendered below the cursor, but quite some 
   pixels off.
 * GPS does not use the standard OSX menu bar. To be able to do this, one
   would need to patch GtkAda to provide the necessary binding to
   GtkOSXApplication and then patch GPS to use it. I currently have no plan to
   do this.
 * This list is not complete and will probably be grow as I use my native GPS.