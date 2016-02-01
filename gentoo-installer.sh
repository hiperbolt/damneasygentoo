#!/bin/bash

## Gentoo Install Script
## 
## Copyleft 2016 Tomás Simões
##
## By: Tomás Simões
## Email: tomasimoes03@gmail.com
##
## This program is free software; you can redistribute it and/or
## modify it under the terms of the Eclipse Public License 1.0
## as published by the Eclipse Foundation.
## 
## Some parts of this software which are properly identified are
## distributed under a different license, in this case it is
## the GNU Public License 2.0
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
## Eclipse Public License Version 1 for more details.
##
## This program was essentially made because I needed to get
## distracted from my parents arguing over my irresponsibility
## all the time, I'm was sick of being treated like shit so I
## wrote this to pass time. Please dont judge too harshly.
## I know my code is a bit shitty.
## Written with <3
##################################################################

#Strings

#Classes
welcome_box() {
	title="Gentoo Installer 0.0.1 Tomas Simoes"
	whiptail --yesno "Welcome to the Gentoo Installer, proceed with instalation?" --title "$title" --yes-button "Yes, proceed." --no-button "No, cancel." 10 70
	
	exitstatus=$?
	if [ $exitstatus = 0 ]; then
		#User proceeded		
		check_arch
	elif [ $exitstatus = 1 ]; then
		#User pressed Cancel		
		echo "exitstatus = 1"
	elif [ $exitstatus = -1 ]; then
		#Something wrong happened		
		echo "exitstatus = -1"
	fi
}

check_arch() {
	whiptail --yesno "Do you wish to install a 32 bit or 64 bit version of Gentoo? ( Sorry but alpha, arm, hppa, ia64, ppc, sparc, mips, s390 and sh not supported )" --title "$title" --yes-button "32 Bit" --no-button "64 Bit" 10 70

	exitstatus=$?
	if [ $exitstatus = 0 ]; then
		echo " guessing its 32"
		architecture="32bits"
		check_connection
	elif [ $exitstatus = 1 ]; then
		echo "guessing its 64"
		architecture="64bits"
		check_connection
	else
		echo " guessing you fucked up m90"
	fi
}

check_connection() {
	title=$title" - Internet Configuration"
	wget -q --spider https://www.gentoo.org/
	exitstatus=$?

	if [ $exitstatus = 0 ]; then
		whiptail --msgbox "Internet connection working." --title "$title" 10 70
		title="Gentoo Installer 0.0.1 Tomas Simoes"
		set_disks
	else
		failed_connection
	fi
}

	failed_connection() {
		CHOICE=$(whiptail --title "$title" --menu "Internet Connection Failed, what to do?" 20 90 10 \
		"Configure Wifi" "Choose this option if you wish to use wifi" \
		"Configure LAN" "Choose this option if you wish to manually configure LAN" \
		"Recheck Network Connection" "Try to recheck your network connection" \
		"Cancel Installation" "Exit the installer" 3>&1 1>&2 2>&3)
		
		if [ "$CHOICE" = "Configure Wifi" ]; then
			set_wifi
		elif [ "$CHOICE" = "Configure LAN" ]; then
			set_lan
		elif [ "$CHOICE" = "recheck Network Connection" ]; then
			check_connection
		else
			clear
			echo " Thanks for using our install script, report to me why you weren't able to install"
		fi
			
	}
		set_wifi() {
			net-setup
			check_connection
		}
		
		set_lan() {
			net-setup
			check_connection		
		}

set_disks() {
	title=$title" - Preparing Disks"
	test -f /sys/firmware/efi
	if [ $? = 0 ]; then
		interfacetype=uefi
	elif [ $? = 1 ]; then
		interfacetype=bios
	else
		failed_interfacetype_detection
	fi
	whiptail --yesno "Do you wish to use MBR (Reccomended) or GPT for your partitions" --yes-button "MBR" --no-button "GPT" --title "$title" 10 70
	exitstatus=$?
	if [ $exitstatus = 0 ]; then
		partitionscheme=mbr
		set_disks2
	else
		partitionscheme=gpt
		set_disks2
	fi
			
	title="Gentoo Installer 0.0.1 Tomas Simoes"
}

	failed_interfacetype_detection() {
		whiptail --yesno "We couldn't detect if your system is using BIOS or UEFI (EFI), please manually select" --yes-button "BIOS" --no-button "UEFI" --title "$title" 10 70
		exitstatus=$?
		if [ $exitstatus = 0 ]; then
			interfacetype=bios
		else
			interfacetype=uefi
		fi
	}

set_disks2() {
	if [ $partitionscheme = "gpt" ] && [ $interfacetype = "bios" ]; then
		whiptail --yesno "You are using GPT and BIOS, this can result in serious issues and not being able to boot the system; do you wish to proceed or re-select?" --yes-button "Proceed" --no-button "Go back" --title "$title" 10 70
		exitstatus=$?
			if [ $exitstatus = 0 ]; then
				set_disks3
			else
				set_disks
			fi
	else
		set_disks3
	fi
}

#Ignore this random string, it was necessary to embed the code belonging to the Arch Linux Anywhere Project here
size="Size"
#This class (set_disks3) is licensed under the GPL 2.0 and belongs to the Arch Linux Anywhere Project
set_disks3() {
	cat <<-EOF > /tmp/part.sh
		#!/bin/bash
		# simple script used to generate block device menu
		whiptail --title "$title" --menu "Please select the drive you wish to use." 20 90 10 \\
		$(lsblk | grep "disk" | awk '{print "\""$1"\"""    ""\"""Type: "$6"    ""'$size': "$4"\""" \\"}' |
		sed "s/\.[0-9]*//;s/ [0-9][G,M]/&   /;s/ [0-9][0-9][G,M]/&  /;s/ [0-9][0-9][0-9][G,M]/& /")
		3>&1 1>&2 2>&3
	EOF
		
	drive=$(bash /tmp/part.sh)
	rm /tmp/part.sh
	set_disks4
}

set_disks4() {
	method1="Particionamento Automático (Recomendado)"
	method2="Particionamento Manual"
	part_method=$(whiptail --menu "Please select the type of partitioning you want" --title "$title" 20 90 10 \
	"$method1" "~" \
	"$method2" "~" 3>&1 1>&2 2>&3)
	
	if [ "$part_method" == "$method1" ]; then
		set_disks5
	else
		echo "hi"
	fi
}

set_disks5() {
#This class is bypassed if you select manual partitioning, classes meet again at set_disks7
	whiptail --yesno "This will delete ALL data on /dev/$drive, are you sure?" --title "$title" 10 70
	exitstatus=$?
}

#
#
#
#
#
#
#
#
welcome_box
