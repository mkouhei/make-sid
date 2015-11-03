#!/bin/sh -e
test -z $1 && exit 1
vmname=$1
VBoxManage snapshot $vmname take $(date +%Y%m%d-%H%M)
if [ $(VBoxManage snapshot $vmname list | wc -l) -lt 4 ]; then
    exit 0
fi
VBoxManage snapshot $vmname delete $(VBoxManage snapshot $vmname list | head -1 | awk '{print $2}')
