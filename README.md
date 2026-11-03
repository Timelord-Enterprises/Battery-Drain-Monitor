# Battery Drain Monitor
This script was created out of frustration :)
Possible scenarios were that a customer complains that the battery drains too fast and during troubleshooting multiple technicians fail to log the battery percentage correctly and on time.

The script writes the battery status, health, hardware configuration and the battery percentage (every hour by default) to a .txt file on the desktop to monitor battery drain. When you stop it with Control-C it adds a summary: total running time, percentage used and the average drain per hour.

The interactive version gives you the option to run a 4K 10h stream of Gandalf the Grey nodding to the sax guy music.

# Dependencies

A laptop running macOS (works with the built-in bash, nothing to install).
Terminal.app might need access to "System Events" to list the running apps.

# How to run the script

Open Terminal.app (located in /Applications/Utilities or Cmd+Shift+U).
Make the scripts executable once:

    chmod u+x Battery_drain_monitor.sh Battery_drain_monitor_interactive.sh

Then drag the script onto the Terminal window, hit enter and the monitoring begins.
Unplug the charger for a valid test; the script warns you if it is still connected.

# Options

    ./Battery_drain_monitor.sh [options]

    -m            Interactive mode: choose a scenario (idle / 4K stream)
    -n MINUTES    Minutes between measurements (default: 60)
    -t PERCENT    Low battery warning threshold (default: 20)
    -o FILE       Results file (default: ~/Desktop/BatteryPercentage.txt)
    -s            Speak each measurement out loud
    -a            Keep the Mac awake (prevents idle sleep while monitoring)
    -h            Show help

`Battery_drain_monitor_interactive.sh` is the same as running `Battery_drain_monitor.sh -m` and accepts the same options.

Example: measure every 15 minutes and keep the Mac awake:

    ./Battery_drain_monitor.sh -n 15 -a
