#!/usr/bin/bash
MEMORY=2048M
DISKSIZE=200G
CPUS=$(getconf _NPROCESSORS_ONLN)
ACCELSUPPORT=$(lscpu | grep VT-x)
echo "You are installing Windows Server 2022 with spice support: $MEMORY memory in a QEMU Virtual Machine";
if [ -z "$ACCELSUPPORT" ]; then echo "KVM Acceleration is not supported by your processor"; 
else echo "$ACCELSUPPORT"
fi
if [ -s "/bin/qemu-img" ]; then echo "All QEMU tools are already installed.";
else if [ -f /usr/bin/apt ]; then sudo apt update && sudo apt install vinagre qemu-system-x86 qemu-utils -y; else yum install qemu-system-x86 qemu qemu-img -y; fi;
fi
if [ -s "disk.qcow2" ]; then echo "$(du disk.qcow2) Found";
else qemu-img create -f qcow2 disk.qcow2 $DISKSIZE;
fi
if [ -s "win2022.iso" ]; then echo "$(du win2022.iso) Found";
else wget -O win2022.iso https://software-download.microsoft.com/download/sg/20348.169.210806-2348.fe_release_svc_refresh_SERVER_EVAL_x64FRE_en-us.iso  --no-check-certificate
fi
sudo pkill qemu;
if [ -z "$ACCELSUPPORT" ]; then sudo qemu-system-x86_64 -boot c -cdrom "win2022.iso" -hda disk.qcow2 -m $MEMORY -M pc -cpu qemu64 -smp $CPUS,cores=1 -vnc :99 -usb -net nic -no-user-config -nodefaults -rtc base=localtime -boot strict=on -chardev pty,id=charserial0 -device isa-serial,chardev=charserial0,id=serial0 -k en-us -device qxl-vga,id=video0,ram_size=67108864,vram_size=67108864,vram64_size_mb=0,vgamem_mb=1531,max_outputs=1 -msg timestamp=on -soundhw hda -spice port=5900,addr=127.0.0.1,disable-ticketing -usb -usbdevice tablet&
else sudo qemu-system-x86_64 -boot c -cdrom "win2022.iso" -hda disk.qcow2 -m $MEMORY -M pc -machine accel=kvm -enable-kvm -cpu max -smp $CPUS,cores=1 -vnc :99 -usb -net nic -no-user-config -nodefaults -rtc base=localtime -boot strict=on -chardev pty,id=charserial0 -device isa-serial,chardev=charserial0,id=serial0 -k en-us -device qxl-vga,id=video0,ram_size=67108864,vram_size=67108864,vram64_size_mb=0,vgamem_mb=1531,max_outputs=1 -msg timestamp=on -soundhw hda -spice port=5900,addr=127.0.0.1,disable-ticketing -usb -usbdevice tablet&
fi
sleep 5;
vinagre "spice://127.0.0.1:5900";
