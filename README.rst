=========================
 Building Sid VBox image
=========================

This script is for building Debian GNU/Linux Sid.
If you use this, change cpus, mems, createVM(), createStorage() in bootstrap.sh, tmpl/*.mustache.

Requirements
============

* OS X
* Python 2.7
* VirtualBox


Default configuration
=====================

* CPU: half of the phisical cpu cores.
* Memory: half of the phisical memory size.
* Storage: 200 GB dynamically expanding storage, and VDI format.
* root user is enabled
* general user creates, and it can uses sudo.
* Partition is atomic.
* See also tmpl/postinstall for additional Debian packages.

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

