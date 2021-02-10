#!/bin/bash
#©copyright Jan Vancoppenolle, Timelord Enterprises
#A script to write away the battery status / Percentage every hour to a .txt file on the desktop with options
#
#Layout
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m' # No Color

CPU=$(sysctl -n hw.ncpu) #determening how many cpu cores are in the system
Yes=$(osascript -e 'tell application "Terminal" CPU=$(sysctl -n hw.ncpu) ; seq $CPU | xargs -I{} -P $CPU yes >/dev/null')
# function stresstest() {

#     echo -e "\nRunning $CPU instances in a seperate Terminal window of ${YELLOW}Yes${NC} on all cores, maxing out all cpu's..."
#     seq $CPU | xargs -I{} -P $CPU yes >/dev/null &
#     #osascript -e 'tell application "Terminal" CPU=$(sysctl -n hw.ncpu) ; seq $CPU | xargs -I{} -P $CPU yes >/dev/null'
# }
function 4K_stream() {
    echo -e "\nOpening browser on 4K stream"
    open -g https://www.youtube.com/embed/xL8-y3oX1R0?autoplay=1 #10h gandalf nodding 4K stream

}
#chooser menu
echo -e ""
echo -e "${GREEN}${BOLD}                         🔋⚡️BATTERY DRAIN MONITOR⚡️🔋${NC}"
echo -e ""
echo -e "${RED}Please choose a battey drain option:${NC}"

echo -e "\n1. Idle (Recomended to test maximum battery life while the Mac is idle)"
echo -e "\n2. Stream a 4K youtube video via the user defined standard browser" #opens a 10h video
# echo -e "\n3. Stress test (Puts every core under 100% load using the ${YELLOW}Yes${NC} command)"
echo -n "Make your choise (1-2):"
read -n 1 scenario
#
if [ $scenario = 2 ]; then
    4K_stream
fi

# if [ $scenario = 3 ]; then
#     stresstest
# fi

echo -e "\n${RED}You chose $scenario${NC}"
echo ""

#
echo -e " "
printf "%55s" "🔋 BATTERY DRAIN MONITOR STARTED 🔋"
echo -e " "
echo -e "\nFor results: Open "BatteryPercentage.txt" On the desktop"

echo -e "\n${RED}${BOLD}Press Control-C to quit the script${NC}"

#Define variables for header
User=$(users)
Date=$(date)
Open_Dock_Apps=$(osascript -e 'tell application "System Events" to get name of (processes where background only is false)')
BatteryStats=$(system_profiler SPPowerDataType | grep -A1 -B7 "Condition")
HardwareConfig=$(system_profiler SPHardwareDataType | grep -A0 -B9 "Memory")
i=$((i + 1))

#Create results text file
touch ~/Desktop/BatteryPercentage.txt
printf "%65s" "🔋BATTERY DRAIN MONITOR🔋" >>~/Desktop/BatteryPercentage.txt
#Write current user session logged in
echo -e "\nCurrent USER signed in: $User" >>~/Desktop/BatteryPercentage.txt
#Write Hardware information
echo -e "\nHardware Information" >>~/Desktop/BatteryPercentage.txt
echo -e "\n$HardwareConfig" >>~/Desktop/BatteryPercentage.txt
#Write battery stats
echo -e "\nBattery Information" >>~/Desktop/BatteryPercentage.txt
echo -e "\n$BatteryStats" >>~/Desktop/BatteryPercentage.txt
echo -e "\n-----------------------------------------------------------------------------------------------------" >>~/Desktop/BatteryPercentage.txt
#Write start Date to script
echo -e "\nScript started on $Date" >>~/Desktop/BatteryPercentage.txt
#Statement to determen chosen option
if [ $scenario = 2 ]; then
    echo -e "\nChosen option: Stream a 4K youtube video via the user defined standard browser." >>~/Desktop/BatteryPercentage.txt
fi
# if [ $scenario = 3 ]; then
#     echo -e "\nChosen option: Stress test " >>~/Desktop/BatteryPercentage.txt
# fi
#Write all open apps
echo -e "\nRunning apps: $Open_Dock_Apps" >>~/Desktop/BatteryPercentage.txt
echo -e "\nResults file creation ✅"

#Loop

while true; do
    #Define variables for results
    BatteryPercentage=$(pmset -g batt | grep -Eo "\d+%" | cut -d% -f1)
    BatteryDrainDate=$(date +%H:%M:%S)

    echo -e "\n$i. $BatteryPercentage% @ $BatteryDrainDate " >>~/Desktop/BatteryPercentage.txt
    ((i = i + 1))
    echo -e "\n- Battery percentage: $BatteryPercentage%, file updated..."
    if [ $BatteryPercentage -lt 20 ]; then
        echo -e "\nBattery percentage is below 20%" >>~/Desktop/BatteryPercentage.txt
        #say Battery percentage is below 20%

    fi

    #Option to have audio feedback
    #say the battery percentage is $BatteryPercentage % at $BatteryDrainDate
    #
    sleep 3600
    


done
