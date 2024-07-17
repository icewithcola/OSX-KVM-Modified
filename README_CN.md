# 这是 [kholia/OSX-KVM](https://github.com/kholia/OSX-KVM) 的简化版本，只保证了一些基本功能

# [English](https://github.com/icewithcola/OSX-KVM-Modified/blob/master/README.md)
# 安装
## 要求
+ `qemu-system-x68_64` 完整软件包
+ `dmg2img` ([AUR](https://aur.archlinux.org/packages/dmg2img),[dpkg](https://packages.debian.org/sid/dmg2img))
+ `virt-manager` （可选）
如果你能使用 v`irt-manager` 运行任何操作系统的 x64 KVM 虚拟机，说明你已经成功安装了 qemu。

## 克隆这个仓库和子模块
```
cd ~

git clone --depth 1 --recursive https://github.com/icewithcola/OSX-KVM-Modified.git

cd OSX-KVM-Modified
```

## 使用非特权 kvm
将用户添加到 `kvm` 和 `libvirt` 组（如果您不想使用root权限运行虚拟机）。
```
sudo usermod -aG kvm $(whoami)
sudo usermod -aG libvirt $(whoami)
sudo usermod -aG input $(whoami)
```

## 获取 BaseSystem
+ 运行 `./fetch-macOS-v2.py`，如果出现 403 错误，请尝试不使用代理。
+ 然后 `dmg2img -i BaseSystem.dmg BaseSystem.img`，现在可以安全地删除 `BaseSystem.dmg`。
+ 使用 `qemu-img create -f qcow2 mac_hdd_ng.img <size>` 创建你的磁盘，`<size>` 为磁盘大小，例如 `256G`。
+ 查看下一节内容，如果一切正常，运行脚本即可。

## 修改脚本 OpenCore-Boot.sh
### 内存
默认情况下我们分配了 32G 内存，可能太大，根据需要减少。
### CPU 配置
如果你没有使用 macOS 14（Sonoma），尝试将 `CPU` 从 `Haswell-noTSX` 更改为 `Penryn`。\
CPU 型号设置为 `host` **有时**也能正常运行，但与 `kvm=on` 参数冲突，在这种情况下，删掉后面那个。
## 网络
```
-netdev bridge,id=net0,br=virbr0
-net nic,model=virtio-net-pci,netdev=net0
```
默认配置使用桥接通过 `virbr0` 访问网络，`virt-manager` 或 `virsh `可以轻松创建此网络桥接。\
如果你不想使用桥接，将这些行替换为
```
-netdev user,id=net0,hostfwd=tcp::2222-:22
-device virtio-net-pci,netdev=net0,id=net0,mac=52:54:00:c9:18:27
```
用于虚拟网络，这意味着每个请求都是由 qemu 自己转发的。在这种情况下，只有 `hostfwd` 参数或使用 `iptables` 才能让你通过 ssh 等访问你的虚拟机。\
如果你遇到 `failed to get mtu of bridge virbr0': No such device `错误，打开 `virt-manager` 可以轻松启动此设备。

## 修复你的系统
### 直接到 UEFI shell
如果每个文件都在，用 `FS0:\EFI\OC\OpenCore.efi` 引导到 OpenCore，**然后重置 NVRAM**。

### 图像显示问题
想办法选中**重置 NVRAM**选项，一般来讲就好了。如果不行，尝试使用另一个 OVMF NVRAM 文件。