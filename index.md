---
layout: default
title: Home
weight: 0
---

## GPS-OSX

**GPS-OSX** is a modified version the [GNAT Programming Studio][1] for OSX.
Compared to the version provided by [AdaCore][2] with GNAT GPL 2013, it
provides the following enhancements:

 * It is built against gtk-quartz and thus does not need an X11 server to run.
 * You can use the command key `⌘` as modifier for keyboard shortcuts. Because
   of this, its configuration files will be incompatible with AdaCore's gps and
   will therefore be placed in `~/.gps-osx` instead of `~/.gps` so that the two
   versions do not interfere with each other.
 * It comes as an app bundle which can simply be dropped into your
   `/Applications` folder.

**Important**: gtk-quartz is considered experimental and you should not expect
this binary to be stable. It also is in no way supported by [AdaCore][2]. Be
aware of this before you decide to use it for any serious software development.

### Download

I host a readily compiled app bundle on my server:

[Download!][4]

This is built on the base of commit
[6284098a177d2ba27050b84798fc163398c23e1f][3].

Please note that I do not plan to create *stable* releases. I just spread the
latest binary I use myself here.

### License

GPS-OSX is available under the terms of the [GNU General Public License, v3][5].

 [1]: http://libre.adacore.com/tools/gps/
 [2]: http://www.adacore.com/
 [3]: https://github.com/flyx86/gps-osx/commit/6284098a177d2ba27050b84798fc163398c23e1f
 [4]: http://flyx.org/files/GPS-6284098.dmg
 [5]: http://www.gnu.org/licenses/gpl.html