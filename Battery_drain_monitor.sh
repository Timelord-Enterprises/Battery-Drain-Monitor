#!/bin/bash
#©copyright Jan Vancoppenolle, Timelord Enterprises
#A script to write away the battery status / Percentage every hour to a .txt file on the desktop
#
#
#
echo " "

echo -e "Battery script Running,for results: Open "BatteryPercentage.txt" On the desktop"
echo " "
echo -e "Press Control-c to quite the script"
echo " "

#Define variables for header
User=$(users)
Date=$(date)

#create results text file
touch ~/Desktop/BatteryPercentage.txt
echo -e "BATTERY DRAIN MONITOR by Timelord Enterprises" >>~/Desktop/BatteryPercentage.txt
#Write current user session logged in
echo -e "\nCurrent USER signed in: $User" >>~/Desktop/BatteryPercentage.txt
#wtite Date to script
echo -e "Script started on $Date" >>~/Desktop/BatteryPercentage.txt

#loop?

while true; do
    #Define variables for results
    BatteryPercentage=$(pmset -g batt | grep -Eo "\d+%" | cut -d% -f1)
    BatteryDrainDate=$(date +%H:%M:%S)

# a=10
# b=20

#     if [ $BatteryPercentage -lt $b ]; then
#         echo -e "\nBattery percentage is below 20%" >>~/Desktop/BatteryPercentage.txt
#         say Battery percentage is below 20%
#     else
#         exit
#     fi

#     if [ $BatteryPercentage -lt $a ]; then
#         echo -e "\nBattery percentage is below 10%" >>~/Desktop/BatteryPercentage.txt
#         say Battery percentage is below 10%
#     else
#         exit
#     fi

    #Option to have audio feedback
    #say the battery percentage is $BatteryPercentage % at $BatteryDrainDate
    #
    echo -e "\n$BatteryPercentage% @ $BatteryDrainDate " >>~/Desktop/BatteryPercentage.txt
    sleep 3600
done
