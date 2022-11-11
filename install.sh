#!/bin/bash
DRIVE='/dev/nvme0n1'
HOSTNAME='laptop'
USER_NAME='samuel'
USER_PASSWORD=''

setup() {
	partition_drive "$DRIVE"
	
	mount_drive "$DRIVE"

	install_base
	
	create_fstab

	cp $0 /mnt/setup.sh
	chmod 777 /mnt/setup.sh

	arch-chroot /mnt ./setup.sh chroot

	echo "Unmounting filesystem"
	echo 'Done! Reboot system.'
		
}

partition_drive() {
	local dev="$1"; shift
	sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | fdisk --wipe-partitions always "$dev"
		o
		n
		p
		1
	
		+512M
		n
		p
		2
		
		+30G
		n
		p
		3
		
		
		
		a
		1
		t
		2
		82
		p
		w
		q
EOF

local boot_dev="${dev}p1"; shift
local swap_dev="${dev}p2"; shift
local home_dev="${dev}p3"; shift

mkfs.fat -F 32 -n EFIBOOT "$boot_dev"
mkswap -L p_swap "$swap_dev"
mkfs.ext4 -L p_arch "$home_dev"
}

mount_drive() {
	mount -L p_arch /mnt
	mkdir /mnt/boot
	mount -L EFIBOOT /mnt/boot
	swapon -L p_swap
}

install_base() {
	pacstrap /mnt base base-devel linux linux-firmware linux-headers
}


create_fstab() {
	genfstab -Lp /mnt > /mnt/etc/fstab
}

set_hostname() {
	local hostname="$1"; shift

	echo "$hostname" > /etc/hostname
}

unmount_filesystem() {
	umount /mnt/boot
	umount /mnt
	swapoff -L p_swap
}

configure() {
	install_bootloader

	set_hostname "$HOSTNAME"

	install_sudo

	echo "Enter the password for user $USER_NAME"
	stty -echo
	read USER_PASSWORD
	stty

	create_user "$USER_NAME" "$USER_PASSWORD"

	pacman --noconfirm -S git 	

	#install_gvm "$USER_NAME"

	install_network_manager
	install_packages
  set_i3_config

}

install_sudo() {
	pacman --noconfirm -S sudo
	groupadd sudo
	cat > /etc/sudoers <<EOF
root ALL=(ALL:ALL) ALL
%sudo	ALL=(ALL:ALL) ALL

@includedir /etc/sudoers.d
EOF
	chmod 440 /etc/sudoers

}

create_user () {
	local name="$1"; shift
	local password="$1"; shift

	useradd -m -s /bin/bash -G sudo "$name"
	echo -en "$password\n$password"  | passwd "$name"
}

install_network_manager() {
	pacman --noconfirm -S dhcpcd networkmanager network-manager-applet
	systemctl enable dhcpcd
	systemctl enable NetworkManager
}


install_gvm() {
	local user="$1"; shift
	su - "$user" -c 'bash < <(curl -s -S -L https://raw.githubusercontent.com/moovweb/gvm/master/binscripts/gvm-installer) && source ~/.gvm/scripts/gvm && gvm install go1.4 -B && gvm use go1.4 && export GOROOT_BOOTSTRAP=$GOROOT && gvm install go1.17 && gvm use go1.17 --default'
}

install_yay() {
	local user="$1"; shift
	local password="$2"; shift

	pacman --noconfirm -S base-devel
	su - "$user" -c 'git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si && echo -en "$password\ny\ny\n"'

}

install_bootloader() {
	pacman --noconfirm -S grub efibootmgr
	grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
	grub-mkconfig -o /boot/grub/grub.cfg
}

set_i3_config() {
	mkdir -p ~/.config/i3 ~/.config/i3status ~/.config/polybar ~/.config/terminator

	curl https://raw.githubusercontent.com/SamuelTJackson/my-os/main/i3/config --output ~/.config/i3/config
	curl https://raw.githubusercontent.com/SamuelTJackson/my-os/main/i3/background.png --output ~/.config/i3/background.png
	curl https://raw.githubusercontent.com/SamuelTJackson/my-os/main/i3status/config --output ~/.config/i3status/config

	curl https://raw.githubusercontent.com/SamuelTJackson/my-os/main/polybar/config --output ~/.config/polybar/config
	curl https://raw.githubusercontent.com/SamuelTJackson/my-os/main/polybar/bluetooth.sh --output ~/.config/polybar/bluetooth.sh
	curl https://raw.githubusercontent.com/SamuelTJackson/my-os/main/polybar/launch.sh --output ~/.config/polybar/launch.sh
	curl https://raw.githubusercontent.com/SamuelTJackson/my-os/main/polybar/toogle-bluetooth.sh --output ~/.config/polybar/toogle-bluetooth.sh
	curl https://raw.githubusercontent.com/SamuelTJackson/my-os/main/polybar/vpn.sh --output ~/.config/polybar/vpn.sh
	curl https://raw.githubusercontent.com/SamuelTJackson/my-os/main/rofi/config.nasi --output ~/.config/polybar/config.nasi
	
	curl https://raw.githubusercontent.com/SamuelTJackson/my-os/main/terminator/config --output ~/.config/terminator/config
}

install_packages() {
	local packages=''

	#General
	packages+='intel-ucode alsa-utils alsa-plugins pavucontrol'

	#Laptop
	packages+='tlp tlp-rdw powertop acpi'

	#i3
	pacman --noconfirm -S xorg-server xorg-xrandr xorg-xinit i3-gaps i3blocks i3lock i3status

	#fonts
	pacman --noconfirm -S tf-dejavu ttf-freefont ttf-liberation ttf-droid ttf-roboto terminus-font


	#pacman --noconfirm -S "$packages"
	pacman --noconfirm -S lightdm lightdm-gtk-greeter --needed
	pacman --noconfirm -S rxvt-unicode rofi --needed

	systemctl enable tlp
	systemctl mask systemd-rfkill.service
	systemctl maks systemd-rfkill.socket
	systemctl enable lightdm
	
	pulseaudion -D
}

if [ "$1" == "chroot" ]
then
	configure
else
	setup
fi
