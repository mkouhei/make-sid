#!/bin/sh -e
test -z $1 && exit 1
VBoxManage startvm $1 --type gui
