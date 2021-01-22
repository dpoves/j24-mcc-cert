#!/bin/sh

# Copyright (c) 2021 David Poves. All rights reserved.

version=1.0

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
echo Generating a default configuration file...
rm $configfile 2>/dev/null
touch $configfile
chmod 640 $configfile
#chown 0:0 $config

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
}

# Set $hostname with the value of the first argument
hostname=$1

# If there was no argument, generate FQDN for the current machine
if [ -z "$hostname "]
then
    hostname=`hostname --fqdn`
fi

# Check configuration
echo Starting! ; sleep 0.25

configfile=./${0}.cfg

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
		if [ "$configfile_permissions" == "-rw-r-----" ]
			then
				echo Correct file permissions
			else
				display_error_message "Incorrect file permissions"
				error =1
		fi
		
	else # Config file doesn't exist
		display_error_message "Configuration file not found"
		create_default_configfile
		echo "New config file created."
		echo "Please, edit and relaunch."
		echo
		exit 0
fi

echo "Config file check finished."

######
# Config file check end
######






## Editable configuration
#Common Name (eg, your name or your server's hostname) []:${hostname}
countryname="GB"
province="Greater London"
city="London"
organisation="Jigsaw24"
organisationalunit="Pre-sales"

## Editable optional configuration
email="test@place.com"
password=""
optionalcompanymame=""



mkdir /etc/mycerts
cd /etc/mycerts


# Create certificate key
openssl genrsa -out ${hostname}.key 2048

# Create Certificate Signing Request
openssl req -new -key ${hostname}.key -out ${hostname}.csr

#Create the request
echo "Creating CSR"
openssl req -new -key ${hostname}.key -out $domain.csr -subj "/C=$countryname/ST=$province/L=$city/O=$organisation/OU=$organisationalunit/CN=${hostname}"

/emailAddress="$email"

countryname=GB
province=Greater London
city=London
organisation=Jigsaw24
organisationalunit=Pre-sales

# sudo su  -
# mkdir -m 770 /Volumes/VideoSAN/2016-2017/Course/WorkgroupFolderName_RS
# chgrp  ADGroupName /Volumes/VideoSAN/2016-2017/Course/WorkgroupFolderName_RS
# chmod g+s /Volumes/VideoSAN/2016-2017/Course/WorkgroupFolderName_RS

# The folder structure we have on the VideoSAN is as follows
# ie year and then subfolders of course
# and then we create the workgroups under the relevant course.

# So in the commands we would replace course by CMP, FILM etc.

# VideoSAN
# 2016-2017
# Faculty/Department:
	#CMP
	#CREAM
	#FILM
	#PROJECTS
	#TRAINING
	#TV
# Workgroup (this will be associated to an AD group)

load_last_settings()
{
# Settings stored in /etc/root6_permissions.cfg
config=/etc/root6_permissions.cfg

# If permissions aren't right don't execute file
# Otherwise load defaults

echo Starting! ; sleep 1

# Does the config file exist?
if ls $config 2> /dev/null
	then
		# Yes, config file exists
		echo Configuration file found!
		echo Checking configuration file...
		
		#Extract config file owner 
		config_owner=`ls -l $config | awk '{ print $3 }'`
		#Extract config file group
		config_group=`ls -l $config | awk '{ print $4 }'`
		#Extract config file permissions
		config_permissions=`ls -l $config | awk '{ print $1 }'`
		
		error=0
		
		#Check if owner is root
		if test -O $config
			then
				echo Correct owner: $config_owner
			else
				echo Incorrect owner: $config_owner
				error=1
		fi
		
		#Check if group is wheel
		if test -G $config
			then
				echo Correct group: $config_group
			else
				echo Incorrect group: $config_group
				error=1
		fi
		
		#Check if permissions are 770
		if [ "$config_permissions" == "-rwxrwx---" ]
			then
				echo Correct file permissions
			else
				error_message "Incorrect file permissions"
				error =1
		fi
		
		
			
	else # Config file doesn't exist
		error_message "Configuration file not found"
		echo Generating a default configuration file...
		create_default_config
		echo "Default config file created."
		echo "Please, relaunch."
		echo
		exit 0
fi

##########
echo "Config file check finished"
##########

# If there were any errors quit
if [ "$error" != "0" ]
	then
		error_message "Errors found in configuration file. It could have been tampered with."
		rm $config 2> /dev/null
		echo "Config file deleted."
		create_default_config
		echo "Default config file created."
		echo "Please, relaunch."
		echo
		exit 0

	else
		echo No permission/ownership issues with the config file.
		echo Loading...
		source $config
fi

sleep 2
}

create_default_config()
{
rm $config 2>/dev/null
touch $config
chmod 770 $config
chown 0:0 $config

echo "# (c) David Poves, 2017">> $config
echo>> $config
echo "#/etc/root6_permissions.cfg">> $config
echo "# chown root:wheel">> $config
echo "# chmod 770">> $config
echo>> $config
echo base_folder="/media/VideoSAN">> $config
echo course_year="2017-2018">> $config
echo course_name=>> $config
echo workgroup_folder=>> $config
echo>> $config
echo group_owner=>> $config
echo permissions=770>> $config
}

save_config()
{
echo "Saving current configuration." 
rm $config 2>/dev/null
touch $config
chmod 770 $config
chown 0:0 $config

echo "# (c) David Poves, 2017">> $config
echo>> $config
echo "#/etc/root6_permissions.cfg">> $config
echo "# chown root:wheel">> $config
echo "# chmod 770">> $config
echo>> $config
echo base_folder="${base_folder}">> $config
echo course_year="${course_year}">> $config
echo course_name="${course_name}">> $config
echo workgroup_folder="${workgroup_folder}">> $config
echo>> $config
echo group_owner="${group_owner}">> $config
echo permissions="${permissions}">> $config

sleep 1 
display_message "Done!"
}


clear_screen()
{
tput clear
}

clean_input_line()
{
tput cup 12  5
echo "                                                   "	
}
display_logo()
{
tput setaf 3
tput smul
tput cup 0 37  ; echo "University of Westminster"
tput sgr0
tput cup 1 40  ; echo "[][][][][][][][][]" ;
tput cup 2 40  ; echo "[]   []    []   []" ;
tput cup 3 40  ; echo "[]   []    []   []" ; 
tput cup 4 40  ; echo "[][][][][][][][][]" ;
tput cup 5 40  ; echo "[]   []    []   []" ;
tput cup 6 40  ; echo "[]   []    []   []" ;
tput cup 7 40  ; echo "[][][][][][][][][]" ;
tput cup 8 40  ; echo "[]   []    []   []" ;   
tput cup 9 40  ; echo "[]   \/    \/   []" ;   
tput cup 10 40 ; echo "|/              \|	$version" ;
tput sgr0
}



error_message()
{
tput rev
tput setaf 1
echo $1
tput sgr0
sleep 2
}

display_message()
{
tput rev
tput setaf 5
echo $1
tput sgr0
sleep 2
}


display_menu_main()
{
clean_input_line
tput rev
tput setaf 2
tput cup 1 5   ; echo "M A I N - M E N U" 
tput sgr0
tput cup 3 5   ; echo "1. Course name"
tput cup 4 5   ; echo "2. Workgroup folder"
tput cup 5 5   ; echo "3. AD group"
tput cup 6 5   ; echo "4. Course year"
tput cup 7 5   ; echo ""
tput cup 8 5   ; echo "5. Apply changes"
tput cup 9 5   ; echo ""
tput cup 10 5  ; echo "0. Exit"
tput sgr0
}

display_menu_basefolder()
{
clean_input_line
tput cup 1 9  ; echo ".----------------------."
tput setaf 4
tput rev
tput cup 2 9  ; echo "| B A S E  F O L D E R |"
tput sgr0 
tput cup 3 9  ; echo ".---------------------."
tput cup 4 9  ; echo "|  Write base folder  |"
tput cup 5 9  ; echo "| or just press Enter |"
tput cup 6 9  ; echo "|     to go back      |"
tput cup 7 9  ; echo ".---------------------."
tput sgr0
}

display_menu_course_year()
{
clean_input_line
tput cup 1 9  ; echo ".----------------------."
tput setaf 4
tput rev
tput cup 2 9  ; echo "| C O U R S E  Y E A R |"
tput sgr0 
tput cup 3 9  ; echo ".----------------------."
tput cup 4 9  ; echo "|  Write course year   |"
tput cup 5 9  ; echo "| or just press Enter  |"
tput cup 6 9  ; echo "|     to go back       |"
tput cup 7 9  ; echo ".---------------------."
tput sgr0
}

display_menu_course_name()
{
clean_input_line
tput cup 1 9  ; echo ".----------------------."
tput setaf 4
tput rev
tput cup 2 9  ; echo "| C O U R S E  N A M E |"
tput sgr0 
tput cup 3 9  ; echo ".----------------------."
tput cup 4 9  ; echo "|  Write course name   |"
tput cup 5 9  ; echo "| or just press Enter  |"
tput cup 6 9  ; echo "|     to go back       |"
tput cup 7 9  ; echo ".---------------------."
tput sgr0
}

display_menu_workgroup_folder()
{
clean_input_line
tput cup 1 9  ; echo ".------------------------."
tput setaf 4
tput rev
tput cup 2 9  ; echo "|    W O R K G R O U P   |"
tput cup 3 9  ; echo "|       F O L D E R      |"
tput sgr0 
tput cup 4 9  ; echo ".------------------------."
tput cup 5 9  ; echo "| Write workgroup folder |"
tput cup 6 9  ; echo "|   name or just press   |"
tput cup 7 9  ; echo "|    Enter to go back    |"
tput cup 8 9  ; echo ".------------------------."
tput sgr0
}

display_menu_group_ownership()
{
clean_input_line
tput cup 1 9 ; echo ".------------------------."
tput setaf 4
tput rev
tput cup 2 9 ; echo "|     A D  G R O U P     |"
tput cup 3 9 ; echo "|   O W N E R S H I P    |"
tput sgr0 
tput cup 4 9 ; echo ".------------------------."
tput cup 5 9 ; echo "| Write the group owner  |"
tput cup 6 9 ; echo "|  or just press Enter   |"
tput cup 7 9 ; echo "|       to go back.      |"
tput cup 8 9 ; echo ".------------------------."
tput sgr0
}

display_menu_permissions()
{
clean_input_line
tput cup 1 9 ; echo ".-------------------------."
tput setaf 4
tput rev
tput cup 2 9 ; echo "|  P E R M I S S I O N S  |"
tput sgr0 
tput cup 3 9 ; echo ".-------------------------."
tput cup 4 9 ; echo "|    Write the folder's   |"
tput cup 5 9 ; echo "|   permissions or just   |"
tput cup 6 9 ; echo "| press Enter to go back. |"
tput cup 7 9 ; echo ".------------------------."
tput sgr0
sleep 1
tput cup 0 38 ; echo ".---------------------------."
tput setaf 5
tput rev
tput cup 1 38 ; echo "|      E X A M P L E S      |"
tput sgr0 
tput cup 2 38  ; echo ".---------------------------."
tput cup 3 38  ; echo "|770 - RW owner & group     |"
tput cup 4 38  ; echo "|      no access for rest   |"
tput cup 5 38  ; echo "|774 - RW for owner & group |"
tput cup 6 38  ; echo "|      read only for rest   |"
tput cup 7 38  ; echo "|777 - RW for everyone      |"
tput cup 8 38  ; echo ".---------------------------."
tput cup 9 38  ; echo "|  770 is the default and   |"
tput cup 10 38 ; echo "|  preferred option here.   |"
tput cup 11 38 ; echo ".---------------------------."
tput sgr0

}


display_current_settings()
{
tput cup 13 0  ; echo "-------------------------------------------------------------------"
tput rev
tput setaf 4
tput cup 14 0  ; echo " CURRENT SETTINGS " 
tput sgr0
tput cup 16 1  ; echo "Current path       : $current_path"

tput cup 18 1  ; echo "Course year        : $course_year"
tput cup 19 1  ; echo "Course name        : $course_name"
tput cup 20 1  ; echo "Workgroup folder   : $workgroup_folder"

tput cup 22 1  ; echo "AD group ownership  : $group_owner"
tput sgr0	
}


update_variables()
{
current_path="${base_folder}/${course_year}/${course_name}/${workgroup_folder}"
}

###########################
#PROGRAMME

clear_screen

# Stop script with a warning if user is not root
if (( $EUID != 0 ))
	then
	error_message "error: You need to be root"
	exit 1
fi

load_last_settings

while :	# Main programme loop
do

update_variables
clear_screen
display_menu_main
display_logo
display_current_settings

tput bold
tput cup 12  5
read -p "Enter your choice : " choice

	case $choice in
		0)	# Exit
			clear_screen
			save_config
			exit 0
			;;
			
		#1)	# Base folder
		#	display_menu_basefolder
		#	base_folder_backup=$base_folder
		#	tput cup 12  5
		#	read -p "Enter base folder path :" base_folder
		#	
		#	# if $base_folder isn't a valid folder then revert value
		#	# Otherwise accept new value
		#	if test -d ${base_folder}
		#		then
		#			echo #The base folder is a valid one
		#		else
		#			# The base folder given is invalid
		#			# Revert to the previous value
		#			base_folder=$base_folder_backup
		#			error_message "That root folder doesn't exist!"
		#	fi
		#	
		#	# Check if Enter was pressed
		#	# and keep the same values before returning
		#	# to main menu
		#	if [[ -z $base_folder ]]
		#		then
		#			# Enter was pressed. Make no changes
		#			base_folder=$base_folder_backup
		#	fi
		#	;;
			
		4)	# Course year
			display_menu_course_year
			course_year_backup=$course_year
			tput cup 12 5
			read -p "Enter course year :" course_year
			
			# Check if Enter was pressed
			# and keep the same values before returning
			# to main menu
			if [[ -z $course_year ]]
				then
					# Enter was pressed. Make no changes
					course_year=$course_year_backup
			fi
			;;
			
		1)	# Course name
			display_menu_course_name
			course_name_backup=$course_name
			tput cup 12 5
			read -p "Enter course name :" course_name
			
			# Check if Enter was pressed
			# and keep the same values before returning
			# to main menu
			if [[ -z $course_name ]]
				then
					# Enter was pressed. Make no changes
					course_name=$course_name_backup
			fi
			;;
		
		2)	# Workgroup folder name
			display_menu_workgroup_folder
			workgroup_folder_backup=$workgroup_folder
			tput cup 12 5
			read -p "Enter workgroup folder :" workgroup_folder
			
			# Check if Enter was pressed
			# and keep the same values before returning
			# to main menu
			if [[ -z $workgroup_folder ]]
				then
					# Enter was pressed. Make no changes
					workgroup_folder=$workgroup_folder_backup
			fi
			;;
					
		3)	# AD Group ownership
			display_menu_group_ownership
			group_owner_backup=$group_owner
			tput cup 12 5
			read -p "Enter the AD group owner :" group_owner
			
			# Check if Enter was pressed
			# and keep the same values before returning
			# to main menu
			if [[ -z $group_owner ]]
				then
					# Enter was pressed. Make no changes
					group_owner=$group_owner_backup
			fi
			;;
			
		#6)	# Permissions
		#	display_menu_permissions
		#	permissions_backup=$permissions
		#	tput cup 12 5
		#	read -p "Enter the permissions for the folder :" permissions
		#	
		#	# Check if Enter was pressed
		#	# and keep the same values before returning
		#	# to main menu
		#	if [[ -z $permissions ]]
		#		then
		#			# Enter was pressed. Make no changes
		#			permissions=$permissions_backup
		#	fi
		#	;;
			
		5)	# Apply changes
			update_variables
			# Check that several variables are active
			# to avoid applying change to root folder
			
			# mkdir -m 770 /Volumes/VideoSAN/2016-2017/Course/WorkgroupFolderName_RS
			mkdir -p -m $permissions "$current_path" 
			# chgrp  ADGroupName /Volumes/VideoSAN/2016-2017/Course/WorkgroupFolderName_RS
			chgrp "$group_owner" "$current_path"
			##chgrp -R "$group_owner" "$current_path"
			# chmod g+s /Volumes/VideoSAN/2016-2017/Course/WorkgroupFolderName_RS
			#chmod -R g+w "$current_path"
			chmod g+s "$current_path"
			#chmod -R g+s "$current_path"
			##chmod -R 770 "$current_path"
			display_message "Done." 
			;;
						
		*)
			error_message "Invalid option!"
			;;
	esac
done

#tput clear
tput sgr0
#tput rc