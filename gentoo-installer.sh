#!/bin/sh

### Gentoo Install Script
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
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
## Eclipse Public License Version 1 for more details.
##################################################################

#Strings

#Classes
welcome_box() {
	title="Gentoo Installer 0.0.1 Tomas Simoes"
	whiptail --yesno "Welcome to the Gentoo Installer, proceed with instalation?" --title "$title" --yes-button "Yes, proceed." --no-button "No, cancel." 10 70
	
	exitstatus=$?
	if [ $exitstatus = 0 ]; then
		#User proceeded		
		check_connection
	elif [ $exitstatus = 1 ]; then
		#User pressed Cancel		
		echo "exitstatus = 1"
	elif [ $exitstatus = -1 ]; then
		#Something wrong happened		
		echo "exitstatus = -1"
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
	whiptail --msgbox " work in progress " --title "$title" 10 70
	title="Gentoo Installer 0.0.1 Tomas Simoes"
}

#Launch
welcome_box
