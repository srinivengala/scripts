#!/bin/bash

ISO_FILE="Downloads/ubuntu-16.04.4-desktop-amd64.iso"
VDI_DIR="$(pwd)/"

echo "$VDI_DIR"

myusage() {
  echo "usage:"
  echo "vbox list"
  echo "vbox create"
  echo "vbox up"
}

mylist() {
  echo "the list"
}

mycreate() {
  ## vboxmanage list ostypes
  echo "*** creating UbuntuSandbox"
  VBoxManage createvm --name "UbuntuSandbox" --ostype "Ubuntu_64" --register

  echo "*** creating vdi"
  VBoxManage createhd --filename $VDI_DIR/UbuntuSandbox.vdi --size 20000

  echo "*** adding sata controller"
  VBoxManage storagectl "UbuntuSandbox" \
     --name "SATA Controller" --add sata \
     --controller IntelAHCI

  echo "*** attaching vdi to sata"
  VBoxManage storageattach "UbuntuSandbox" \
      --storagectl "SATA Controller" --port 0 \
      --device 0 --type hdd \
      --medium $VDI_DIR/UbuntuSandbox.vdi

  echo "*** adding acpi/cd device"
  VBoxManage modifyvm "UbuntuSandbox" \
      --memory 2048 --acpi on \
      --boot1 dvd \
      --nic1 bridged --bridgeadapter1 eth0

  echo "*** adding IDE controller"
  VBoxManage storagectl "UbuntuSandbox" --name "IDE Controller" --add ide
  
  echo "*** loading iso"
  VBoxManage storageattach "UbuntuSandbox" \
      --storagectl "IDE Controller" --port 0 --device 0 \
      --type dvddrive \
      --medium "$ISO_FILE"

#VBoxManage modifyvm $VM --ioapic on
#VBoxManage modifyvm $VM --boot1 dvd --boot2 disk --boot3 none --boot4 none
#VBoxManage modifyvm $VM --memory 1024 --vram 128
#VBoxManage modifyvm $VM --nic1 bridged --bridgeadapter1 e1000g0
#VBoxManage snapshot $VM take <name of snapshot>
#VBoxManage snapshot $VM restore <name of snapshot>


  #eject dvd
  #VBoxManage storageattach "UbuntuSandbox" \
  #   --storagectl "IDE Controller" --port 0 --device 0 \
  #   --type dvddrive --medium none
}

up() {
  echo "up you can RDP to console vboxhost:3389"
  VBoxHeadless -s "UbuntuSandbox"
}

if [ $# -eq 0 ]; then
	myusage
	exit 1
fi

if [ "$1" != "" ]; then
  case "$1" in
    create)
      mycreate
      exit 0
      ;;
    up)
      myup
      exit 0
      ;;
    list)
      mylist
      exit 0
      ;;
    *)
      myusage
      exit 1
  esac
fi
