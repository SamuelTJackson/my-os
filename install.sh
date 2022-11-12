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

	install_sudo "$USER_NAME"

	echo "Enter the password for user $USER_NAME"
	stty -echo
	read USER_PASSWORD
	stty

	create_user "$USER_NAME" "$USER_PASSWORD"

	pacman --noconfirm -S git 	

#	install_gvm "$USER_NAME"
	install_yay "$USER_NAME"

	install_network_manager
	install_packages
	set_i3_config "$USER_NAME"
	add_xinit "$USER_NAME"

}

install_sudo() {
	local user="$1"; shift
	pacman --noconfirm -S sudo
	groupadd sudo
	cat > /etc/sudoers <<EOF
root ALL=(ALL:ALL) ALL
%sudo	ALL=(ALL:ALL) ALL
$user ALL=(ALL) NOPASSWD:ALL

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

	su - "$user" -c 'git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si --noconfirm'

}

install_bootloader() {
	pacman --noconfirm -S grub efibootmgr
	grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
	grub-mkconfig -o /boot/grub/grub.cfg
}

set_i3_config() {
	local user="$1"; shift
	
	mkdir -p "/home/${user}/.config/i3" "/home/${user}/.config/i3status" "/home/${user}/.config/polybar" "/home/${user}/.config/terminator" "/home/${user}/.local/share/fonts" "/home/${user}/.config/nvim/lua/plugins"

	curl https://raw.githubusercontent.com/SamuelTJackson/my-os/main/i3/config --output  "/home/${user}/.config/i3/config"
	curl https://raw.githubusercontent.com/SamuelTJackson/my-os/main/i3/background.png --output  "/home/${user}/.config/i3/background.png"
	curl https://raw.githubusercontent.com/SamuelTJackson/my-os/main/i3status/config --output   "/home/${user}/.config/i3status/config"

	curl https://raw.githubusercontent.com/SamuelTJackson/my-os/main/polybar/config --output  "/home/${user}/.config/polybar/config"
	curl https://raw.githubusercontent.com/SamuelTJackson/my-os/main/polybar/bluetooth.sh --output  "/home/${user}/.config/polybar/bluetooth.sh"
	chmod +x  "/home/${user}/.config/polybar/bluetooth.sh"

	curl https://raw.githubusercontent.com/SamuelTJackson/my-os/main/polybar/launch.sh --output  "/home/${user}/.config/polybar/launch.sh"
	chmod +x  "/home/${user}/.config/polybar/launch.sh"

	curl https://raw.githubusercontent.com/SamuelTJackson/my-os/main/polybar/toggle-bluetooth.sh --output  "/home/${user}/.config/polybar/toggle-bluetooth.sh"
	chmod +x  "/home/${user}/.config/polybar/toggle-bluetooth.sh"

	curl https://raw.githubusercontent.com/SamuelTJackson/my-os/main/polybar/vpn.sh --output  "/home/${user}/.config/polybar/vpn.sh"
	chmod +x  "/home/${user}/.config/polybar/vpn.sh"

	curl https://raw.githubusercontent.com/SamuelTJackson/my-os/main/rofi/config.nasi --output  "/home/${user}/.config/polybar/config.nasi"
	
	curl https://raw.githubusercontent.com/SamuelTJackson/my-os/main/terminator/config --output  "/home/${user}/.config/terminator/config"


	curl https://raw.githubusercontent.com/SamuelTJackson/my-os/main/fonts/3270-Medium%20Nerd%20Font%20Complete%20Mono.ttf --output  "/home/${user}/.local/share/fonts/3270-Medium Nerd Font Complete Mono.ttf"

	curl https://raw.githubusercontent.com/SamuelTJackson/my-os/main/fonts/FiraCode-SemiBold.ttf --output  "/home/${user}/.local/share/fonts/FiraCode-SemiBold.ttf"

	curl https://raw.githubusercontent.com/SamuelTJackson/my-os/main/fonts/JetBrainsMono-ExtraBold.ttf --output  "/home/${user}/.local/share/fonts/JetBrainsMono-ExtraBold.ttf"
	
	curl https://raw.githubusercontent.com/SamuelTJackson/my-os/main/fonts/JetBrainsMono-SemiBold.ttf --output  "/home/${user}/.local/share/fonts/JetBrainsMono-SemiBold.ttf"

	curl https://raw.githubusercontent.com/SamuelTJackson/my-os/main/fonts/MaterialIcons-Regular.ttf --output  "/home/${user}/.local/share/fonts/MaterialIcons-Regular.ttf"

	curl https://raw.githubusercontent.com/SamuelTJackson/my-os/main/fonts/JetBrains%20Mono%20Regular%20Nerd%20Font%20Complete%20Mono.ttf --output  "/home/${user}/.local/share/fonts/JetBrains Mono Regular Nerd Font Complete Mono.ttf"
	
	curl https://raw.githubusercontent.com/SamuelTJackson/my-os/main/nvim/init.lua --output  "/home/${user}/.config/nvim/init.lua"
	curl https://raw.githubusercontent.com/SamuelTJackson/my-os/main/nvim/lua/init.lua --output  "/home/${user}/.config/nvim/lua/init.lua"
	curl https://raw.githubusercontent.com/SamuelTJackson/my-os/main/nvim/lua/auto-commands.lua --output  "/home/${user}/.config/nvim/lua/auto-commands.lua"
	curl https://raw.githubusercontent.com/SamuelTJackson/my-os/main/nvim/lua/key-mappings.lua --output  "/home/${user}/.config/nvim/lua/key-mappings.lua"
	curl https://raw.githubusercontent.com/SamuelTJackson/my-os/main/nvim/lua/plugins.lua --output  "/home/${user}/.config/nvim/lua/plugins.lua"
	curl https://raw.githubusercontent.com/SamuelTJackson/my-os/main/nvim/lua/settings.lua --output  "/home/${user}/.config/nvim/lua/settings.lua"
	curl https://raw.githubusercontent.com/SamuelTJackson/my-os/main/nvim/lua/utils.lua --output  "/home/${user}/.config/nvim/lua/utils.lua"
	curl https://raw.githubusercontent.com/SamuelTJackson/my-os/main/nvim/lua/plugins/autopairs.lua --output  "/home/${user}/.config/nvim/lua/plugins/autopairs.lua"
	curl https://raw.githubusercontent.com/SamuelTJackson/my-os/main/nvim/lua/plugins/bufferline.lua --output  "/home/${user}/.config/nvim/lua/plugins/bufferline.lua"
	curl https://raw.githubusercontent.com/SamuelTJackson/my-os/main/nvim/lua/plugins/colorizer.lua --output  "/home/${user}/.config/nvim/lua/plugins/colorizer.lua"
	curl https://raw.githubusercontent.com/SamuelTJackson/my-os/main/nvim/lua/plugins/lualine.lua --output  "/home/${user}/.config/nvim/lua/plugins/lualine.lua"
	curl https://raw.githubusercontent.com/SamuelTJackson/my-os/main/nvim/lua/plugins/nvim-tree.lua --output  "/home/${user}/.config/nvim/lua/plugins/nvim-tree.lua"
	curl https://raw.githubusercontent.com/SamuelTJackson/my-os/main/nvim/lua/plugins/nvim-web-devicons.lua --output  "/home/${user}/.config/nvim/lua/plugins/nvim-web-devicons.lua"
	curl https://raw.githubusercontent.com/SamuelTJackson/my-os/main/nvim/lua/plugins/treesitter.lua --output  "/home/${user}/.config/nvim/lua/plugins/treesitter.lua"

	
	chown -R "${user}:${user}" "/home/${user}/.config"
	chown -R "${user}:${user}" "/home/${user}/.local"
}

add_xinit() {
	local user="$1"; shift
	echo "exec i3" > "/home/${user}/.xinitrc"

}

install_packages() {
	local packages=''
	set -e

	#General
	packages+='intel-ucode pulseaudio alsa-utils alsa-plugins pavucontrol terminator scrot polybar neovim google-chrome'

	#i3
	packages+=' xorg-server xorg-xrandr xorg-xinit i3-gaps i3status rofi i3lock'

	#fonts
	packages+=' noto-fonts-emoji ttf-dejavu'


	yay --noconfirm -S ${packages}
	#pacman --noconfirm -S lightdm lightdm-gtk-greeter --needed
	#pacman --noconfirm -S rxvt-unicode rofi --needed

	#systemctl mask systemd-rfkill.service
	#systemctl mask systemd-rfkill.socket
	#systemctl enable lightdm
	
	pulseaudio -D
}

if [ "$1" == "chroot" ]
then
	configure
else
	setup
fi
