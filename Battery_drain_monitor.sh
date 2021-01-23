#!/bin/bash
#©copyright Jan Vancoppenolle, Timelord Enterprises
#A script to write away the battery status / Percentage every hour to a .txt file on the desktop
#
#
#chooser menu
# echo -e "\nChoose a battey drain option:"
#
# echo -e "\n1. Idle, run without open apps (Recomended to test maximum battery life while the Mac is idle)"
# echo -e "\n2. Stream a 4K youtube video via the standard browser" #opens a 10h video
# echo -e "\n3. Stress test (Puts every core under 100% load using the Yes command)"
# #
#option 2
#open https://youtu.be/xL8-y3oX1R0
#option 3
#CPU=$(sysctl -n hw.ncpu)
#seq $CPU | xargs -I{} -P $CPU yes > /dev/null
#
echo -e " "
printf "%55s" "🔋BATTERY DRAIN MONITOR🔋"
echo -e " "
echo -e "\nBattery drain script Running,for results: Open "BatteryPercentage.txt" On the desktop"

echo -e "\nPress Control-C to quit the script"

#Define variables for header
User=$(users)
Date=$(date)
Open_Dock_Apps=$(osascript -e 'tell application "System Events" to get name of (processes where background only is false)')
BatteryStats=$(system_profiler SPPowerDataType | grep -A1 -B7 "Condition")
HardwareConfig=$(system_profiler SPHardwareDataType | grep -A0 -B9  "Memory")
i=$((i + 1))


#Create results text file
touch ~/Desktop/BatteryPercentage.txt
printf "%65s" "🔋BATTERY DRAIN MONITOR🔋" >>~/Desktop/BatteryPercentage.txt
#Write current user session logged in
echo -e "\nCurrent USER signed in: $User" >>~/Desktop/BatteryPercentage.txt
#Write all open apps
echo -e "\nRunning apps: $Open_Dock_Apps" >>~/Desktop/BatteryPercentage.txt
#Write Hardware information
echo -e "\nHardware Information" >>~/Desktop/BatteryPercentage.txt
echo -e "\n$HardwareConfig" >>~/Desktop/BatteryPercentage.txt
#Write battery stats
echo -e "\nBattery Information" >>~/Desktop/BatteryPercentage.txt
echo -e "\n$BatteryStats" >>~/Desktop/BatteryPercentage.txt
echo -e "\n-----------------------------------------------------------------------------------------------------" >>~/Desktop/BatteryPercentage.txt
#Write start Date to script
echo -e "\nScript started on $Date" >>~/Desktop/BatteryPercentage.txt

#Loop

while true; do
    #Define variables for results
    BatteryPercentage=$(pmset -g batt | grep -Eo "\d+%" | cut -d% -f1)
    BatteryDrainDate=$(date +%H:%M:%S)

    echo -e "\n$i. $BatteryPercentage% @ $BatteryDrainDate " >>~/Desktop/BatteryPercentage.txt
    ((i = i + 1))
    
        if [ $BatteryPercentage -lt 20 ]; then
            echo -e "\nBattery percentage is below 20%" >>~/Desktop/BatteryPercentage.txt
            #say Battery percentage is below 20%
            
        fi


    #Option to have audio feedback
    #say the battery percentage is $BatteryPercentage % at $BatteryDrainDate
    #
    sleep 5

done
