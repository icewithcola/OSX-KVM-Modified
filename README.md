# This is a simplified version of [kholia/OSX-KVM](https://github.com/kholia/OSX-KVM), with only base system on normal PC

# Insatall
## Requirements
+ `qemu-system-x68_64` full package
+ `dmg2img` ([AUR](https://aur.archlinux.org/packages/dmg2img),[dpkg](https://packages.debian.org/sid/dmg2img))

If you can run a x64 KVM vm with any OS with `virt-manager`, it means you have successfully installed qemu.

## Use non-previleged kvm
Add user to the `kvm` and `libvirt` groups (might be needed).
```
sudo usermod -aG kvm $(whoami)
sudo usermod -aG libvirt $(whoami)
sudo usermod -aG input $(whoami)
```

## Clone this repo and submodules
```
cd ~

git clone --depth 1 --recursive https://github.com/icewithcola/OSX-KVM-Modified.git

cd OSX-KVM-Modified
```

## Get BaseSystem
+ Run `./fetch-macOS-v2.py` if got 403, try not use proxy.
+ Then `dmg2img -i BaseSystem.dmg BaseSystem.img`, and now you are safe to delete `BaseSystem.dmg`.
+ Use `qemu-img create -f qcow2 mac_hdd_ng.img <size>` to create your disk with `<size>`, like `256G`.
+ See next section, if okay, go and run the script and it will be okay.

## Modify Script `OpenCore-Boot.sh`
### Memory
On default we alloc 32G mem which can be too big, decrease if needed.
### CPU Config
If you are not using macOS 14(Sonoma), try change `CPU` from `Haswell-noTSX` to `Penryn`.\
`host` cpu model **may** work, but conficts `kvm=on` parameter, in this case, just remove later. 
### Network
```
-netdev bridge,id=net0,br=virbr0
-net nic,model=virtio-net-pci,netdev=net0
```
Default config use bridge to reach your network via virbr0, `virt-manager` or `virsh` can create this net bridge easily. \
If you don't want use bridge, replace these lines to 
```
-netdev user,id=net0,hostfwd=tcp::2222-:22
-device virtio-net-pci,netdev=net0,id=net0,mac=52:54:00:c9:18:27
```
for a virtual network, means every request is forwarded by qemu itself. And in this case, only `hostfwd` param or use `iptables` can let you reach your VM with ssh etc..

## Fix your system
### Boot into UEFI shell
If every file is just there, use `FS0:\EFI\OC\OpenCore.efi` to boot into OpenCore and then **Reset NVRAM**
### Strange Video
Try your best to reach **Reset NVRAM** and will fix. If not, try use another OVMF NVRAM file.