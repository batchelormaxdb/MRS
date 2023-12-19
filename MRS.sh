#!/bin/bash
#At any point, if the user wishes to exit, the following message will appear
function cancel {
	if [[ $? -eq 1 ]]
	then
		dialog --colors --msgbox "\Z5Goodbye! :)" 0 0
		clear
		exit
	fi
}

loop=1 #Variable for continuing looping
#List of all available cities to travel to and from
while [[ $loop -eq 1 ]]
do
	declare -A cities
	cities[6]="New-York"
	cities[5]="Seattle"
	cities[4]="Tokyo"
	cities[3]="Chicago"
	cities[2]="Portland"
	cities[1]="San-Francisco"
	cities[0]="Miami"
	
	isName=0
	while [[ $isName -eq 0 ]]
	do
		name=$(dialog --colors --inputbox "\Z4Enter your name: " --output-fd 1 0 0)
		cancel
		if [[ $name =~ [^A-Za-z\ \-] ]] #Checks if the user's name consists of letters only
		then
			dialog --colors --msgbox "\Z1Please enter in a name!" 0 0
		else 
			isName=1
		fi
	done
	#Below reads the user's name from an existing res.txt
	if grep -q "^$name," res.txt;  then
	        IFS=',' read -ra user_info <<< "$(grep "^$name," res.txt)"
	        bags=${user_info[1]}
	        dcal=${user_info[2]}
	        departChoice=${user_info[3]}
	        rcal=${user_info[4]}
	        arrivalChoice=${user_info[5]}
	        #Below shows a confirmation dialog box
	        dialog --colors --yesno "\Z5Name: $name \nDeparture City: $departChoice \nArrival City: $arrivalChoice \nDeparture Date: $dcal \nReturn Date: $rcal \nNumber of bags: $bags \n \Z1Do you want to replace this flight?" 0 0
	        if [[ $? -eq 1 ]]
	        then
	                dialog --colors --msgbox "   \Z5Reservation kept. Have a nice flight!" 5 45
			clear
	                exit
	        fi
	fi
	
#--------------------------------------------------------
	cityOptions=()
	for city in "${!cities[@]}"
	do
	    cityOptions+=("$city ${cities[$city]}")
	done
	depart=$(dialog --colors --no-tags --menu "\Z4Select Departure City: " --output-fd 1 0 0 0 ${cityOptions[@]})
	cancel
	#Sets the output of depart to a temporary variable named choice
	departChoice=${cities[$depart]}
	#Unsets the index # of choice from the cityOptions array
	#
	if [[ $departChoice == "New-York" ]]
	then
	    unset cityOptions[0]
	fi
	if [[ $departChoice == "Seattle" ]]
	then
	    unset cityOptions[1]
	fi
	if [[ $departChoice == "Tokyo" ]]
	then
	    unset cityOptions[2]
	fi
	if [[ $departChoice == "Chicago" ]]
	then
	    unset cityOptions[3]
	fi
	if [[ $departChoice == "Portland" ]]
	then
	    unset cityOptions[4]
	fi
	if [[ $departChoice == "San-Francisco" ]]
	then
	    unset cityOptions[5]
	fi
	if [[ $departChoice == "Miami" ]]
	then
	    unset cityOptions[6]
	fi
	arrival=$(dialog --colors --no-tags --menu "\Z4Select Arrival City: " --output-fd 1 0 0 0 ${cityOptions[@]})
	cancel
	arrivalChoice=${cities[$arrival]}
	
	#Calendar for Departing and Arriving Dates
	today=$(date +"%s" -d "$(date +"%Y/%m/%d")")
	
	beforeToday=1
	while [[
		beforeToday -eq 1 ]]
	do
	        dcal=$(dialog --colors --calendar "\Z4Departure Date from \Z1$departChoice:" --output-fd 1 0 0)
		cancel
	        dcal=$(echo "$dcal" | awk -F'/' '{print $2"/"$1"/"$3}')
	        departDate=$(date -d "$dcal" +%s)
	        if [[ "$departDate" -lt "$today" ]]
	        then
	                dialog --colors --msgbox "\Z1Please pick a date from today onwards!" 0 0
	        else
	        
			beforeToday=0
	        fi
	done
	
	beforeDepart=1
	while [[ $beforeDepart -eq 1 ]]
	do
	        rcal=$(dialog --colors --calendar "\Z4Return Date from \Z1$arrivalChoice:" --output-fd 1 0 0)
		cancel
	        rcal=$(echo "$rcal" | awk -F'/' '{print $2"/"$1"/"$3}')
	        returnDate=$(date -d "$rcal" +%s)
	        if [[ "$returnDate" -lt "$departDate" ]]
	        then
	                dialog --colors --msgbox "\Z1Please pick a date after your departing date!" 0 0
	        else
	                beforeDepart=0
	        fi
	done
	
	#Input Check Bags
	isNumber=0
	while [[ $N -eq 0 ]]
	do
		bags=$(dialog --colors --inputbox "\Z4How many bags will be checked?" --output-fd 1 0 35 )
		cancel
		if [[ "$bags" =~ [^0-9] ]]
		then
			dialog --colors --msgbox "\Z1Please enter in a number!" 0 0
		else
			N=1
		fi
	done
	
	dialog --colors --yesno "\Z4Name: \Z1$name \n\Z4Departure City: \Z1$departChoice \n\Z4Arrival City: \Z1$arrivalChoice \n\Z4Departure Date: \Z1$dcal \n\Z4Return Date: \Z1$rcal \n\Z4Number of bags: \Z1$bags \n \Z4Is this information correct?" 0 0
	if [[ $? -eq 0 ]]
	then
	        dialog --colors --msgbox "    \Z5Have a nice flight!" 5 25 # :)
	loop=0
	fi
done

#Return Information to Terminal
clear
echo "Name: $name"
echo "Departing to $departChoice on $dcal"
echo "Returning from $arrivalChoice on $rcal"
echo "Bags Checked: $bags"

sed -i "/^$name\b/d" res.txt
echo "$name,$bags,$dcal,$departChoice,$rcal,$arrivalChoice" >> res.txt
