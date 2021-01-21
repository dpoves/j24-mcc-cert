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
                exit 0 ####
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