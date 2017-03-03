vim-dbus-server
===============

vim-dbus-server provides a DBus service that allows vim to be controlled
by other processes in the same DBus session. It can be used as a
replacement for the built-in vim server when working without a GUI.

There are lots of reasons why raw vim might be preferred over gvim. The 
author uses it primarily when working remotely with mosh+tmux.

Contributing
------------

Patches are welcome, either via github.com pull requests or using
`git send-email`.

Rather to my surprise the bulk of the effort in getting this plugin to
work well had nothing to do with DBus communication (as you can see, the
entire server code fits onto a single screen). Instead the biggest
investment turned out to be the argument handling in the dvim script.

As a result, although this is *currently* a DBus server it is (or should
be) cheap and easy to drop in any other communication technology.
Patches to support additional mechanisms for IPC will certainly be
considered. Who knows... I might even rename the project.

License
-------

Copyright (C) Daniel Thompson.  Distributed under the same terms as Vim
itself. See `:help license`.
