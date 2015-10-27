=========================
 Building Sid VBox image
=========================

This script is for building Debian GNU/Linux Sid.
If you use this, change createVM() in bootstrap.sh, tmpl/*.mustache.

Requirements
============

* OS X
* Python 2.7
* VirtualBox

Usage
=====

Execute as follow::

  $ ./bootstrap.sh ``vm name``.


Clean up
--------

kill SimpleHTTPServer process::

  $ pkill -f 'python -m SimpleHTTPServer'


Delete VBox image when installing fails,::

  $ VBoxManage unregistervm ``vm name`` --delete

