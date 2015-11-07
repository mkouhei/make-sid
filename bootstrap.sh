#!/bin/sh -e

test -z $1 && exit 1
name=$1

pylib=$(pwd)/.pylib

cpus=$(( $(sysctl -n hw.ncpu) / 2))
mems=$(( $(sysctl -n hw.memsize) / 1024 ** 2 / 2))
iso=debian-testing-amd64-netinst.iso
url=http://cdimage.debian.org/cdimage/daily-builds/daily/arch-latest/amd64/iso-cd/${iso}
netboot=http://ftp.debian.org/debian/dists/stretch/main/installer-amd64/current/images/netboot/netboot.tar.gz

basepath=${HOME}/VirtualBox\ VMs/${name}
diskpath="${basepath}/${name}.vdi"

download() {
echo "### download ###"
install -d $pylib
PYTHONPATH=$pylib easy_install -d $pylib passlib pystache tftpy

install -d download
(
cd download
if [ ! -f ${iso} ]; then
curl -C - -L -O ${url}
fi

if [ ! -f netboot.tar.gz ]; then
curl -C - -L -O $netboot
fi
)
}

start_httpd() {
echo "### start httpd ###"
if ! curl -s http://localhost:8000 >/dev/null ; then
(
cd public
python -m SimpleHTTPServer &
httpd_pid=$!
)
fi
}

start_tftp_server() {
echo "### start tftp server ###"
install -d boot
if [ -f download/netboot.tar.gz ]; then
(
cd boot
tar zxf ../download/netboot.tar.gz

echo $sudopw | sudo -S python ../run.py &
tftp_pid=$!
)
fi
}

createVM() {
echo "### create VM ###"
VBoxManage list vms | grep -qw $name || VBoxManage createvm --name $name --register
VBoxManage modifyvm $name \
    --ostype Debian_64 \
    --memory $mems \
    --vram 128 \
    --acpi on \
    --ioapic on \
    --hpet off \
    --paravirtprovider kvm \
    --hwvirtex on \
    --nestedpaging on \
    --largepages on \
    --vtxvpid on \
    --vtxux on \
    --pae off \
    --longmode on \
    --cpuid-portability-level 0 \
    --cpus $cpus \
    --cpuexecutioncap 100 \
    --rtcuseutc on \
    --monitorcount 1 \
    --accelerate3d on \
    --accelerate2dvideo off \
    --firmware bios \
    --chipset piix3 \
    --biossystemtimeoffset 100 \
    --boot1 disk \
    --boot1 net \
    --boot2 floppy \
    --boot4 dvd \
    --nic1 nat \
    --nictype1 82540EM \
    --cableconnected1 on \
    --nictrace1 off \
    --nicbootprio1 0 \
    --nicpromisc1 deny \
    --macaddress1 auto \
    --mouse usbmultitouch \
    --keyboard ps2 \
    --audio coreaudio \
    --audiocontroller hda \
    --audiocodec stac9221 \
    --clipboard bidirectional \
    --draganddrop disabled \
    --vrde off \
    --usb on \
    --usbehci on \
    --snapshotfolder default \
    --tracing-enabled off \
    --autostart-enabled off \
    --autostart-delay 0 \
    --videocap off \
    --defaultfrontend default \
    --nattftpserver1 10.0.2.2 \
    --nattftpfile1 pxelinux.0
}

createStorage() {
echo "### create storage ###"
test ! -f "$diskpath" && VBoxManage list hdds | grep -qw "$diskpath" || VBoxManage createmedium disk --filename "$diskpath" \
    --size $(( 200 * 1024 )) \
    --format VDI \
    --variant Standard
VBoxManage storagectl $name --name IDE --add ide --controller PIIX4 --portcount 2 --hostiocache on
VBoxManage storagectl $name --name SATA --add sata --controller IntelAHCI --portcount 2
VBoxManage storageattach $name --storagectl IDE --port 1 --type dvddrive --device 0 --medium download/${iso}
VBoxManage storageattach $name --storagectl SATA --port 0 --type hdd --medium "$diskpath"
}

installOS() {
echo "### install OS ###"
VBoxManage startvm $name --type gui
}

generate_preseed() {
install -d public
read -sp "Input sudo password: " sudopw
echo
read -sp "Input root password: " rootpw
echo
read -p "Input full name: " fullname
read -p "Input user name: " username
read -sp "Input user password: " userpw
echo

PYTHONPATH=$pylib python gen_preseed.py -r "$rootpw" -f "$fullname" -u "$username" -p "$userpw"
}

download
generate_preseed
start_httpd
#start_tftp_server
createVM
createStorage
installOS
