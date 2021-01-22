#!/bin/sh

# Copyright (c) 2021 David Poves. All rights reserved.

version=1.0

####
# Functions
####

display_error_message()
{
	tput rev
	tput setaf 1
	echo $1
	tput sgr0
	sleep 1
}

####
# Configuration functions
####
create_default_configfile()
{
	echo "Deleting existing configuration file."
	rm $configfile 2>/dev/null
	touch $configfile
	chmod 640 $configfile
	#chown 0:0 $config

	#####
	echo "# (c) 2021 David Poves. All rights reserved."> $configfile
	echo>> $configfile

	echo "# This file's permissions:">> $configfile
	echo "# chmod 640">> $configfile
	echo>> $configfile

	echo "#Common Name (the machine's FQDN) is called as an argument or automatically extracted. It isn't included with the configuration.">> $configfile
	echo>> $configfile

	echo 'countryname="GB"'>> $configfile
	echo 'province="Greater London"'>> $configfile
	echo 'city="London"'>> $configfile
	echo 'organisation="Jigsaw24"'>> $configfile
	echo 'organisationalunit="Pre-sales"'>> $configfile
	echo>> $configfile

	echo '## Optional configuration'>> $configfile
	echo '#email="test@place.com"'>> $configfile
	echo '#password=""'>> $configfile
	echo '#optionalcompanymame=""'>> $configfile
	#####
	echo "New default configuration file created."
}

load_configuration()
{
	# Is there a config file?
	if [ -f "$configfile" ]
    	then
			# Yes config file exists
        	# Check the configuration file
        	# You don't need to be an admin or root to generate the files, but installing them later on would require that.

        	# Check that the config file doesn't have anything that shouldn't be there.
        	# Mind you, it is possible to craft variables to contain malicious code.
        	# Shell script isn't great for this kind of thing.

        	# Get the config file ownership and permissions
        	# We will only check permissions, but the code is here for reference.

			#configfile_owner=`ls -l $configfile | awk '{ print $3 }'`
			#configfile_group=`ls -l $configfile | awk '{ print $4 }'`
        	# Ownership can be tested with
        	# test -O $configfile
			# test -G $configfile

			configfile_permissions=`ls -l $configfile | awk '{ print $1 }'`

        	# The configuration file should only have the fields we are going to use.

			#Check if permissions are 640
			if [ "$configfile_permissions" = "-rw-r-----" ]
				then
					echo "Correct configuration file permissions found."
				else
					display_error_message "Incorrect configuration file permissions."
                	create_default_configfile
					error=1
			fi


        	# Has the configuration file any variable that shouldn't be there?
        	# Check by
        	# Removing lines that start with blank or #
        	# grep "^[^#:blank:]" $configfile
        	# And checking for lines that don't have the variables we expect.
        	if [ -z `grep "^[^#:blank:]" $configfile |\
                	egrep -v \
                	-e "^countryname=*" \
                	-e "^province=*" \
                	-e "^city=*" \
                	-e "^organisation=*" \
                	-e "^organisationalunit=*"` ]
            	then
                	echo Configuration file seems good.
                	# Load configuration
                	source $configfile
                	echo
                	echo "Loaded configuration"
                	echo "===================="
                	echo "Domain               : $hostname"
                	echo "Country code         : $countryname"
                	echo "Province             : $province"
                	echo "City                 : $city"
                	echo "Company name         : $organisation"
                	echo "Department           : $organisationalunit"
                	sleep 2
                	error=0
            	else
                	display_error_message "Configuration file seems to have been tampered with."
                	error=2
           	fi
		else # Config file doesn't exist
			error=3        
	fi

	# If any errors were detected generate a new config file
	if [ "$error" != "0" ]
    	then
        	display_error_message "Error: $error Bad or missing configuration file."
        	create_default_configfile
	fi

	echo
	echo "Config file check finished."
}

###
# Menu functions
###
menu_clear_screen()
{
	tput clear
}

menu_clean_input_line()
{
	tput cup 12  5
echo "                                                   "
}

menu_display_logo()
{
	tput setaf 3
	tput smul
	tput cup 0 22  ; echo "Server certificate generation v.$version"
	tput sgr0
	tput cup 20 40  ; echo "|| Blog   : https://pov.es            ||" ;
	tput cup 21 40  ; echo "|| GitHub : https://github.com/dpoves ||" ;
	tput cup 4 40  ; echo "" ;
	tput cup 5 40  ; echo "" ;
	tput cup 6 40  ; echo "" ; 

	tput cup 7 40  ; echo "" ;
	tput cup 8 40  ; echo "" ;
	tput cup 9 40  ; echo "" ;   
	tput cup 10 40 ; echo "" ;   
	tput sgr0
}

menu_display_main()
{
	menu_clean_input_line
	tput rev
	tput setaf 2
	tput cup 1 9   ; echo "MENU"
	tput sgr0
	tput cup 2 1    ; echo ".-------------------."
	tput cup 3 1    ; echo "| 1. Folder         |"
	tput cup 4 1    ; echo "|-------------------|"
	tput cup 5 1    ; echo "| 2. Country code   |"
	tput cup 6 1    ; echo "| 3. Province       |"
	tput cup 7 1    ; echo "| 4. City           |"
	tput cup 8 1    ; echo "| 5. Organisation   |"
	tput cup 9 1    ; echo "| 6. Department     |"
	tput cup 10 1    ; echo "|-------------------|"
	#tput cup 11 1   ; echo "| 9. Optional       |"
	tput cup 12 1   ; echo "|-------------------|"
	tput cup 13 1   ; echo "| g. Generate certs |"
	tput cup 14 1   ; echo "| x. Exit           |"
	tput cup 15 1   ; echo "'-------------------'"
	tput sgr0
}

menu_display_current_settings()
{
tput rev
tput setaf 4
tput cup 1 23  ; echo "CURRENT SETTINGS" 
tput sgr0
tput cup 3 23  ; echo "current path $current_path"

tput cup 5 23  ; echo "country $countryname"
tput cup 6 23  ; echo "province $province"
tput cup 7 23  ; echo "city $city"
tput cup 8 23  ; echo "organisation $organisation"
tput cup 9 23  ; echo "department $organisationalunit"
tput sgr0		
}


#Check configuration
#Load configuration
load_configuration
menu_clear_screen
menu_display_logo
menu_display_main
menu_display_current_settings
tput cup 24
exit 0
###
# End of menu functions
###

####
# End of functions
####


####
# Script start
####

# Set $hostname with the value of the first argument
hostname=$1

# If there was no argument, generate FQDN for the current machine
if [ -z "$hostname" ]
then
    hostname=`hostname --fqdn`
fi

# Check configuration
echo Starting! ; sleep 0.25

configfile=${0}.cfg

######
# Config file check start
######
# Is there a config file?
if [ -f "$configfile" ]
    then # Yes config file exists
        # Check the configuration file
        # You don't need to be an admin or root to generate the files, but installing them later on would require that.

        # Check that the config file doesn't have anything that shouldn't be there.
        # Mind you, it is possible to craft variables to contain malicious code.
        # Shell script isn't great for this kind of thing.

        # Get the config file ownership and permissions
        # We will only check permissions, but the code is here for reference.

		#configfile_owner=`ls -l $configfile | awk '{ print $3 }'`
		#configfile_group=`ls -l $configfile | awk '{ print $4 }'`
        # Ownership can be tested with
        # test -O $configfile
		# test -G $configfile

		configfile_permissions=`ls -l $configfile | awk '{ print $1 }'`

        # The configuration file should only have the fields we are going to use.

		#Check if permissions are 640
		if [ "$configfile_permissions" = "-rw-r-----" ]
			then
				echo "Correct configuration file permissions found."
			else
				display_error_message "Incorrect configuration file permissions."
                create_default_configfile
				error=1
		fi


        # Has the configuration file any variable that shouldn't be there?
        # Check by
        # Removing lines that start with blank or #
        # grep "^[^#:blank:]" $configfile
        # And checking for lines that don't have the variables we expect.
        if [ -z `grep "^[^#:blank:]" $configfile |\
                egrep -v \
                -e "^countryname=*" \
                -e "^province=*" \
                -e "^city=*" \
                -e "^organisation=*" \
                -e "^organisationalunit=*"` ]
            then
                echo Configuration file seems good.
                # Load configuration
                source $configfile
                echo
                echo "Loaded configuration"
                echo "===================="
                echo "Domain               : $hostname"
                echo "Country code         : $countryname"
                echo "Province             : $province"
                echo "City                 : $city"
                echo "Company name         : $organisation"
                echo "Department           : $organisationalunit"
                sleep 2
                error=0
            else
                display_error_message "Configuration file seems to have been tampered with."
                error=2
		fi
	else # Config file doesn't exist
		error=3        
fi

# If any errors were detected generate a new config file
if [ "$error" != "0" ]
    then
        display_error_message "Error: $error Bad or missing configuration file."
        create_default_configfile
		echo
        echo "Please, edit configuration and relaunch."
		echo
		exit 0
fi

echo
echo "Config file check finished."
######
# Config file check end
######

###
# Create certificates
###
# Create certificate key
echo
echo "Generating certificate key ${hostname}.key"
openssl genrsa -out ${hostname}.key 2048

#Create the Certificate Signing Request
echo
echo "Creating Certificate Signing Request"
openssl req -new \
    -key ${hostname}.key \
    -out ${hostname}.csr \
    -subj "/C=$countryname/ST=$province/L=$city/O=$organisation/OU=$organisationalunit/CN=${hostname}"
###
# End of certificates creation
###

###
# Summary
###
echo
echo "Your files are stored in the current directory."
echo
echo "Your certificate key is:"
echo "========================"
cat ${hostname}.key
echo
echo "Your CSR is:"
echo "========================"
cat ${hostname}.csr
echo

# Check FQDN
#if [ "echo $hostname | grep -o '\.' | wc -l" -lt 2 ]
# How many dots are in the FQDN?
dots=`echo $hostname | grep -o '\.' | wc -l`
# Convert $dots from string to numeric
dots=$(($dots+0))
# If the FQDN has less than two dots it might not be a FQDN.
if [ $dots -lt 2 ]
    then
        echo
        display_error_message "FQDN seems too short, please double check."
        echo
fi

exit 0