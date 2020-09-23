#!/usr/bin/bash
MEMORY=2048M
DISKSIZE=200G
CPUS=$(getconf _NPROCESSORS_ONLN)
ACCELSUPPORT=$(lscpu | grep Virt)
echo "You are installing Windows Server 2019 with spice support: $MEMORY memory in a QEMU Virtual Machine";
if [ -z "$ACCELSUPPORT" ]; then echo "KVM Acceleration is not supported by your processor"; 
else echo "$ACCELSUPPORT"
fi
if [ -s "/bin/qemu-img" ]; then echo "All QEMU tools are already installed.";
else sudo apt update && sudo apt install vinagre qemu-system-x86 qemu-utils -y;
fi
if [ -s "disk.qcow2" ]; then echo "$(du disk.qcow2) Found";
else qemu-img create -f qcow2 disk.qcow2 $DISKSIZE;
fi
if [ -s "win2019.iso" ]; then echo "$(du win2019.iso) Found";
else wget -O win2019.iso https://is.gd/winserver2019 --no-check-certificate
fi
sudo pkill qemu;
if [ -z "$ACCELSUPPORT" ]; then sudo qemu-system-x86_64 -boot c -cdrom "win2019.iso" -hda disk.qcow2 -m $MEMORY -M pc -cpu qemu64,hv_relaxed,hv_vapic,hv_spinlocks=0x1fff -smp $CPUS,cores=1 -vnc :99 -usb -overcommit mem-lock=on -net nic -net user,hostfwd=tcp::22222-:22 -no-user-config -nodefaults -rtc base=localtime -no-hpet -no-shutdown -boot strict=on -chardev pty,id=charserial0 -device isa-serial,chardev=charserial0,id=serial0 -k en-us -device qxl-vga,id=video0,ram_size=67108864,vram_size=67108864,vram64_size_mb=0,vgamem_mb=1531,max_outputs=1 -device virtio-balloon-pci,id=balloon0,bus=pci.0,addr=0x6 -msg timestamp=on -soundhw hda -spice port=5900,addr=127.0.0.1,disable-ticketing -usb -usbdevice tablet&
else sudo qemu-system-x86_64 -boot c -cdrom "win2019.iso" -hda disk.qcow2 -m $MEMORY -M pc -machine accel=kvm -enable-kvm -cpu max,hv_relaxed,hv_vapic,hv_spinlocks=0x1fff -smp $CPUS,cores=1 -vnc :99 -usb -overcommit mem-lock=on -net nic -net user,hostfwd=tcp::22222-:22 -no-user-config -nodefaults -rtc base=localtime -no-hpet -no-shutdown -boot strict=on -chardev pty,id=charserial0 -device isa-serial,chardev=charserial0,id=serial0 -k en-us -device qxl-vga,id=video0,ram_size=67108864,vram_size=67108864,vram64_size_mb=0,vgamem_mb=1531,max_outputs=1 -device virtio-balloon-pci,id=balloon0,bus=pci.0,addr=0x6 -msg timestamp=on -soundhw hda -spice port=5900,addr=127.0.0.1,disable-ticketing -usb -usbdevice tablet&
fi
sleep 3;
vinagre "spice://127.0.0.1:5900";
