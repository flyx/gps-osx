---
layout: default
title: Developer Documentation
weight: 4
---

## Developer Documentation

This information is only relevant if you would like to contribute to GPS-OSX.

### Repository Layout

The GPS sources from AdaCore are contained in the branch `upstream`. It is an
orphan branch with no parents. If AdaCore releases a new version, it will be
checked in into `upstream` and will then be merged into the other branches.

The other two code branches are `develop` and `master`. They are childs of
`upstream`. Usually, `develop` is based upon the latest `master` revision.
I do my work there and then merge it into `master`, which serves as base for
building binaries. If you want to send a pull request, commit your work into
`develop`.

### Opening the source code in GPS

To be able to do this, you need to have the jhbuild/gtk-quartz toolchain
installed (follow the instruction in the readme file). You also need to build
and install GtkAda and XMLAda into the jhbuild directory (usually `~/gtk/inst`)
and change the `ADA_PROJECT_PATH` of your GPS app bundle to
`~/gtk/inst/lib/gnat` so that GPS finds these two libraries (see the _Usage_
page). Before opening the source, you should navigate to the source folder in
the terminal and execute:

{% highlight sh %}
 jhbuild shell
 export GPR_PROJECT_PATH=$PREFIX/lib/gnat
 export PATH=$PREFIX/bin:$PATH
 ./configure --prefix=$PREFIX --with-python=$PREFIX/bin/python --enable-gpl
 exit
{% endhighlight %}

This generates the project file `gnatlib/gnatcoll_shared.gpr`. After that, you
should be able to open `gps/gps.gpr` into GPS. If you want to actually build
GPS from inside GPS, well, good luck - I never tried that. A starting point
would be `build-gps.sh`, where the lines above are taken from. In addition, you
need to figure out what the Makefile does and tell GPS to do exactly that.