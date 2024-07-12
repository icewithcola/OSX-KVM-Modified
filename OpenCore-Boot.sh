#!/usr/bin/env bash

ALLOCATED_RAM="32768" # MiB
CPU_SOCKETS="1"
CPU_CORES="2"
CPU_THREADS="4"

REPO_PATH=$(dirname $0)
OVMF_DIR="OVMF"

CPU="Haswell-noTSX" # Penryn if not macOS Sonoma, `host` **may** also work but please delete `kvm=on` param

args=(
  -enable-kvm -m "$ALLOCATED_RAM" -cpu "$CPU",kvm=on,vendor=GenuineIntel,+invtsc,vmware-cpuid-freq=on,+ssse3,+sse4.2,+popcnt,+avx,+aes,+xsave,+xsaveopt,check
  -machine q35
  -device qemu-xhci,id=xhci
  -device usb-kbd,bus=xhci.0 -device usb-tablet,bus=xhci.0
  -smp "$CPU_THREADS",cores="$CPU_CORES",sockets="$CPU_SOCKETS"
  -device usb-ehci,id=ehci
  -device isa-applesmc,osk="ourhardworkbythesewordsguardedpleasedontsteal(c)AppleComputerInc"
  -drive if=pflash,format=raw,readonly=on,file="$REPO_PATH/$OVMF_DIR/OVMF_CODE.fd"
  -drive if=pflash,format=raw,file="$REPO_PATH/$OVMF_DIR/OVMF_VARS-1920x1080.fd"
  -smbios type=2
  -device ich9-intel-hda -device hda-duplex
  -device ich9-ahci,id=sata
  -drive id=OpenCoreBoot,if=none,snapshot=on,format=qcow2,file="$REPO_PATH/OpenCore/OpenCore.qcow2"
  -device ide-hd,bus=sata.2,drive=OpenCoreBoot
  -device ide-hd,bus=sata.3,drive=InstallMedia
  -drive id=InstallMedia,if=none,file="$REPO_PATH/BaseSystem.img",format=raw
  -drive id=MacHDD,if=none,file="$REPO_PATH/mac_hdd_ng.img",format=qcow2
  -device ide-hd,bus=sata.4,drive=MacHDD
  -netdev bridge,id=net0,br=virbr0
  -net nic,model=virtio-net-pci,netdev=net0
  -monitor stdio
  -device vmware-svga
)

if [[ `cat /sys/module/kvm/parameters/ignore_msrs` = 'N' ]] ; then 
  echo 'Setting KVM env ...'
  echo 1 > sudo tee /sys/module/kvm/parameters/ignore_msrs;
fi
qemu-system-x86_64 "${args[@]}"
