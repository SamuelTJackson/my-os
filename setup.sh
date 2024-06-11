#!/bin/bash

DRIVE='/dev/nvme0n1'
HOSTNAME='laptop'
USER_NAME='samuel'
USER_PASSWORD=''

setup() {
    pacman -Sy archlinux-keyring

	partition_drive "$DRIVE"

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
local home_dev="${dev}p2"; shift

cryptsetup --batch-mode luksFormat "$home_dev"
cryptsetup open "$home_dev" cryptlvm

pvcreate /dev/mapper/cryptlvm
vgcreate Laptop /dev/mapper/cryptlvm

lvcreate -L 32G Laptop -n swap
lvcreate -L 64G Laptop -n root
lvcreate -l 100%FREE Laptop -n home

mkfs.ext4 /dev/Laptop/root
mkfs.ext4 /dev/Laptop/home
mkswap /dev/Laptop/swap
mkfs.fat -F32 "$boot_dev"

mount /dev/Laptop/root /mnt
mount --mkdir /dev/Laptop/home /mnt/home
swapon /dev/Laptop/swap
mount --mkdir "$boot_dev" /mnt/boot
blkid "$home_dev" -s UUID -o value > /mnt/uuid
}

install_base() {
	pacstrap /mnt base base-devel linux linux-firmware linux-headers lvm2
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
	set_timezone

 	configure_mkinitcpio

	install_bootloader

	set_hostname "$HOSTNAME"

	install_sudo "$USER_NAME"

	create_user "$USER_NAME" "$USER_PASSWORD"

	pacman --noconfirm -S git
	install_network_manager

	install_yay "$USER_NAME"

	install_packages
 	enable_services
	set_i3_config "$USER_NAME"
	add_xinit "$USER_NAME"
	add_zsh_config "$USER_NAME"
	setup_touchpad
}

set_timezone() {
	ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime
 	hwclock --systohc
  	echo "en_US.UTF-8 UTF-8" >> /etc/locale.get
   	locale-gen
    touch /etc/locale.conf
    echo "LANG=en_US.UTF-8" > /etc/locale.conf
    pacman -Sy archlinux-keyring
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

	useradd -m -s /bin/bash -G sudo,video "$name"
	echo -en "$password\n$password"  | passwd "$name"
}

install_network_manager() {
	pacman --noconfirm -S dhcpcd networkmanager network-manager-applet networkmanager-openvpn
	systemctl enable dhcpcd
	systemctl enable NetworkManager
}

install_yay() {
	local user="$1"; shift

	su - "$user" -c 'git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si --noconfirm'
}

configure_mkinitcpio() {
	sed -i 's/HOOKS=(base udev autodetect modconf kms keyboard keymap consolefont block filesystems fsck)/HOOKS=(base udev autodetect modconf kms keyboard keymap consolefont block encrypt lvm2 filesystems fsck)/g' /etc/mkinitcpio.conf
 	mkinitcpio -P
}

install_bootloader() {
	pacman --noconfirm -S grub efibootmgr
	grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
 	uuid=$(cat /uuid)
  	rm /uuid
   	sed -i 's#GRUB_CMDLINE_LINUX=""#GRUB_CMDLINE_LINUX="cryptdevice=UUID='"$uuid"':cryptlvm root=/dev/Laptop/root"#g' /etc/default/grub
	grub-mkconfig -o /boot/grub/grub.cfg
}

set_i3_config() {
	local user="$1"; shift

	mkdir -p "/home/${user}/.local/scripts" "/home/${user}/.config/i3" "/home/${user}/.config/dunst" "/home/${user}/.config/i3status" "/home/${user}/.config/polybar" "/home/${user}/.config/kitty" "/home/${user}/.local/share/fonts"  "/home/${user}/.config/tmux"

	curl https://raw.githubusercontent.com/SamuelTJackson/my-os/main/i3/config --output  "/home/${user}/.config/i3/config"
	curl https://raw.githubusercontent.com/SamuelTJackson/my-os/main/i3/background.png --output  "/home/${user}/.config/i3/background.png"
	curl https://raw.githubusercontent.com/SamuelTJackson/my-os/main/i3status/config --output   "/home/${user}/.config/i3status/config"

	curl https://raw.githubusercontent.com/SamuelTJackson/my-os/main/polybar/config --output  "/home/${user}/.config/polybar/config"
	curl https://raw.githubusercontent.com/SamuelTJackson/my-os/main/polybar/bluetooth.sh --output  "/home/${user}/.config/polybar/bluetooth.sh"
	chmod +x  "/home/${user}/.config/polybar/bluetooth.sh"

	curl https://raw.githubusercontent.com/SamuelTJackson/my-os/main/polybar/launch.sh --output  "/home/${user}/.config/polybar/launch.sh"
	chmod +x  "/home/${user}/.config/polybar/launch.sh"

 	curl https://raw.githubusercontent.com/SamuelTJackson/my-os/main/polybar/audio.sh --output  "/home/${user}/.config/polybar/audio.sh"
	chmod +x  "/home/${user}/.config/polybar/audio.sh"

	curl https://raw.githubusercontent.com/SamuelTJackson/my-os/main/polybar/toggle-bluetooth.sh --output  "/home/${user}/.config/polybar/toggle-bluetooth.sh"
	chmod +x  "/home/${user}/.config/polybar/toggle-bluetooth.sh"

	curl https://raw.githubusercontent.com/SamuelTJackson/my-os/main/polybar/vpn.sh --output  "/home/${user}/.config/polybar/vpn.sh"
	chmod +x  "/home/${user}/.config/polybar/vpn.sh"

	curl https://raw.githubusercontent.com/SamuelTJackson/my-os/main/rofi/config.nasi --output  "/home/${user}/.config/polybar/config.nasi"

	curl https://raw.githubusercontent.com/SamuelTJackson/my-os/main/kitty/config --output  "/home/${user}/.config/kitty/config"


	curl https://raw.githubusercontent.com/SamuelTJackson/my-os/main/fonts/3270-Medium%20Nerd%20Font%20Complete%20Mono.ttf --output  "/home/${user}/.local/share/fonts/3270-Medium Nerd Font Complete Mono.ttf"

	curl https://raw.githubusercontent.com/SamuelTJackson/my-os/main/fonts/FiraCode-SemiBold.ttf --output  "/home/${user}/.local/share/fonts/FiraCode-SemiBold.ttf"

	curl https://raw.githubusercontent.com/SamuelTJackson/my-os/main/fonts/JetBrainsMono-ExtraBold.ttf --output  "/home/${user}/.local/share/fonts/JetBrainsMono-ExtraBold.ttf"

	curl https://raw.githubusercontent.com/SamuelTJackson/my-os/main/fonts/JetBrainsMono-SemiBold.ttf --output  "/home/${user}/.local/share/fonts/JetBrainsMono-SemiBold.ttf"

	curl https://raw.githubusercontent.com/SamuelTJackson/my-os/main/fonts/MaterialIcons-Regular.ttf --output  "/home/${user}/.local/share/fonts/MaterialIcons-Regular.ttf"

	curl https://raw.githubusercontent.com/SamuelTJackson/my-os/main/fonts/JetBrains%20Mono%20Regular%20Nerd%20Font%20Complete%20Mono.ttf --output  "/home/${user}/.local/share/fonts/JetBrains Mono Regular Nerd Font Complete Mono.ttf"

	curl https://raw.githubusercontent.com/SamuelTJackson/my-os/main/dunst/dunstrc --output  "/home/${user}/.config/dunst/dunstrc"

	chown -R "${user}:${user}" "/home/${user}/.config"
	chown -R "${user}:${user}" "/home/${user}/.local"


	curl https://raw.githubusercontent.com/SamuelTJackson/my-os/main/tmux/tmux.conf --output  "/home/${user}/.config/tmux/tmux.conf"

	curl https://raw.githubusercontent.com/SamuelTJackson/my-os/main/scripts/tmux-sessionizer --output  "/home/${user}/.local/scripts/sessionizer"
	chmod +x  "/home/${user}/.local/scripts/sessionizer"


	curl https://raw.githubusercontent.com/SamuelTJackson/my-os/main/greenclip/greenclip.toml --output  "/home/${user}/.config/greenclip.toml"

    curl -L -o /usr/bin/greenclip https://github.com/erebe/greenclip/releases/download/v4.2/greenclip
}

add_nvim_config(){
    git clone https://github.com/SamuelTJackson/nvim.git "/home/${user}/.config/nvim"
}

add_zsh_config() {
	local user="$1"; shift

	su - "$user" -c 'sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended'

	curl https://raw.githubusercontent.com/SamuelTJackson/my-os/main/zsh/.zshrc --output  "/home/${user}/.zshrc"
	chown "${user}:${user}" "/home/${user}/.zshrc"
	mkdir -p "/home/${user}/.oh-my-zsh/custom/themes" "/home/${user}/.oh-my-zsh/custom/plugins"


	curl -L https://raw.githubusercontent.com/sbugzu/gruvbox-zsh/master/gruvbox.zsh-theme > "/home/${user}/.oh-my-zsh/custom/themes/gruvbox.zsh-theme"
	git clone https://github.com/zsh-users/zsh-autosuggestions "/home/${user}/.oh-my-zsh/custom/plugins/zsh-autosuggestions"

	chown -R "${user}:${user}" "/home/${user}/.oh-my-zsh"
}

# chrome://flags/#enable-native-notifications
setup_touchpad() {
	cat >> "/etc/X11/xorg.conf.d/30-touchpad.conf" <<EOF
Section "InputClass"
    Identifier "touchpad"
    Driver "libinput"
    MatchIsTouchpad "on"
    Option "Tapping" "on
    Option "ClickMethod" "clickfinger"
    Option "NaturalScrolling" "false"
EndSection
EOF
}

add_xinit() {
	local user="$1"; shift
	echo "exec i3" > "/home/${user}/.xinitrc"

}

install_packages() {
	local packages=''
	set -e

   	pacman --noconfirm -S "intel-ucode"
   	pacman --noconfirm -S "pulseaudio"
   	pacman --noconfirm -S "alsa-utils"
   	pacman --noconfirm -S "alsa-plugins"
   	pacman --noconfirm -S "pavucontrol"
   	pacman --noconfirm -S "kitty"
   	pacman --noconfirm -S "scrot"
   	pacman --noconfirm -S "polybar"
   	pacman --noconfirm -S "neovim"
   	pacman --noconfirm -S "zsh"
   	pacman --noconfirm -S "xclip"
   	pacman --noconfirm -S "dunst"
   	pacman --noconfirm -S "libinput"
   	pacman --noconfirm -S "archlinux-keyring"
   	pacman --noconfirm -S "blueman"
   	pacman --noconfirm -S "pulseaudio-bluetooth"
   	pacman --noconfirm -S "sof-firmware"
   	pacman --noconfirm -S "less"
   	pacman --noconfirm -S "rofi-greenclip"
   	pacman --noconfirm -S "xorg-server"
   	pacman --noconfirm -S "xorg-xrandr"
   	pacman --noconfirm -S "xorg-xinit"
   	pacman --noconfirm -S "i3-gaps"
   	pacman --noconfirm -S "rofi"
   	pacman --noconfirm -S "i3lock"
   	pacman --noconfirm -S "rofi-greenclip"
   	pacman --noconfirm -S "arandr"
   	pacman --noconfirm -S "i3-gaps"
   	pacman --noconfirm -S "noto-fonts-emoji"
   	pacman --noconfirm -S "ttf-dejavu"

	pulseaudio -D
}

enable_services() {
	systemctl start bluetooth
 	systemctl enable bluetooth
 }

if [ "$1" == "chroot" ]
then
	configure
else
	setup
fi
