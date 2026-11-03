#!/bin/bash
# ©copyright Jan Vancoppenolle, Timelord Enterprises
#
# Battery Drain Monitor
# Logs the battery status, health, hardware configuration and battery
# percentage at a fixed interval to a .txt file on the desktop, so battery
# drain complaints can be verified with reliable, timestamped data.
#
# Written for the stock macOS bash (3.2), no extra dependencies.

set -u

VERSION="2.0"

# ---------------------------------------------------------------------------
# Defaults (can be overridden with command line options, see usage)
# ---------------------------------------------------------------------------
INTERVAL_MIN=60                              # minutes between measurements
LOW_THRESHOLD=20                             # warn below this percentage
OUTPUT_FILE="$HOME/Desktop/BatteryPercentage.txt"
INTERACTIVE=0                                # show the scenario menu
SPEAK=0                                      # audio feedback via `say`
KEEP_AWAKE=0                                 # prevent idle sleep (caffeinate)
SCENARIO="Idle"
STREAM_URL="https://www.youtube.com/embed/xL8-y3oX1R0?autoplay=1"  # 10h 4K stream

# ---------------------------------------------------------------------------
# Layout
# ---------------------------------------------------------------------------
if [ -t 1 ]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BOLD='\033[1m'
    NC='\033[0m'
else
    RED='' GREEN='' YELLOW='' BOLD='' NC=''
fi

SEPARATOR="-----------------------------------------------------------------------------------------------------"

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
usage() {
    cat <<EOF
Battery Drain Monitor v$VERSION

Usage: $(basename "$0") [options]

Options:
  -m            Interactive mode: choose a battery drain scenario from a menu
  -n MINUTES    Minutes between measurements (default: $INTERVAL_MIN)
  -t PERCENT    Low battery warning threshold (default: $LOW_THRESHOLD)
  -o FILE       Results file (default: ~/Desktop/BatteryPercentage.txt)
  -s            Speak each measurement out loud
  -a            Keep the Mac awake (prevents idle sleep while monitoring)
  -h            Show this help

Press Control-C to stop monitoring; a summary is written to the results file.
EOF
}

die() {
    echo -e "${RED}Error:${NC} $*" >&2
    exit 1
}

log() {
    # Append a line to the results file
    echo -e "$*" >>"$OUTPUT_FILE"
}

is_number() {
    case "$1" in
        '' | *[!0-9]*) return 1 ;;
        *) return 0 ;;
    esac
}

battery_percentage() {
    pmset -g batt | grep -Eo '[0-9]+%' | head -n 1 | tr -d '%'
}

power_source() {
    # "AC Power" or "Battery Power"
    pmset -g batt | head -n 1 | sed -n "s/.*'\(.*\)'.*/\1/p"
}

charge_state() {
    # charging / discharging / charged / AC attached / finishing charge
    pmset -g batt | sed -n '2p' | awk -F';' '{gsub(/^ +| +$/, "", $2); print $2}'
}

# ---------------------------------------------------------------------------
# Scenarios
# ---------------------------------------------------------------------------
start_4k_stream() {
    echo -e "\nOpening the default browser on a 4K stream..."
    open -g "$STREAM_URL"
}

choose_scenario() {
    echo ""
    echo -e "${GREEN}${BOLD}                         🔋⚡️BATTERY DRAIN MONITOR⚡️🔋${NC}"
    echo ""
    echo -e "${RED}Please choose a battery drain option:${NC}"
    echo -e "\n1. Idle (recommended to test maximum battery life while the Mac is idle)"
    echo -e "\n2. Stream a 4K YouTube video via the default browser"
    echo ""

    local choice
    while true; do
        printf "Make your choice (1-2): "
        read -r -n 1 choice
        echo ""
        case "$choice" in
            1) SCENARIO="Idle"; break ;;
            2) SCENARIO="Stream a 4K YouTube video via the default browser"; start_4k_stream; break ;;
            *) echo -e "${YELLOW}Invalid choice, please enter 1 or 2.${NC}" ;;
        esac
    done

    echo -e "\n${RED}You chose: $SCENARIO${NC}"
}

# ---------------------------------------------------------------------------
# Results file header
# ---------------------------------------------------------------------------
write_header() {
    local open_apps battery_stats hardware_config

    open_apps=$(osascript -e 'tell application "System Events" to get name of (processes where background only is false)' 2>/dev/null)
    [ -z "$open_apps" ] && open_apps="(unavailable - give Terminal access to \"System Events\")"

    battery_stats=$(system_profiler SPPowerDataType 2>/dev/null |
        grep -E "Cycle Count|Condition|Maximum Capacity|Full Charge Capacity|State of Charge|Fully Charged|Charging:" |
        sed 's/^ *//')
    hardware_config=$(system_profiler SPHardwareDataType 2>/dev/null |
        grep -E "Model Name|Model Identifier|Chip|Processor|Cores|Memory|Serial Number|System Firmware" |
        sed 's/^ *//')

    printf "%65s\n" "🔋BATTERY DRAIN MONITOR🔋" >>"$OUTPUT_FILE"
    log "\nCurrent USER signed in: $(users)"
    log "macOS version: $(sw_vers -productVersion 2>/dev/null)"
    log "\nHardware Information\n"
    log "$hardware_config"
    log "\nBattery Information\n"
    log "$battery_stats"
    log "\n$SEPARATOR"
    log "\nScript started on $(date)"
    log "Chosen option: $SCENARIO"
    log "Measurement interval: $INTERVAL_MIN minute(s)"
    log "\nRunning apps: $open_apps"
    log ""
}

# ---------------------------------------------------------------------------
# Summary on exit
# ---------------------------------------------------------------------------
START_EPOCH=""
START_PERCENT=""
CAFFEINATE_PID=""

finish() {
    trap - INT TERM EXIT
    [ -n "$CAFFEINATE_PID" ] && kill "$CAFFEINATE_PID" 2>/dev/null

    if [ -n "$START_EPOCH" ] && [ -n "$START_PERCENT" ]; then
        local end_epoch end_percent elapsed_min drained rate
        end_epoch=$(date +%s)
        end_percent=$(battery_percentage)
        elapsed_min=$(((end_epoch - START_EPOCH) / 60))

        log "\n$SEPARATOR"
        log "\nScript stopped on $(date)"
        log "Total running time: $((elapsed_min / 60))h $((elapsed_min % 60))m"
        if is_number "$end_percent"; then
            drained=$((START_PERCENT - end_percent))
            log "Battery: $START_PERCENT% -> $end_percent% (${drained}% used)"
            if [ "$elapsed_min" -gt 0 ]; then
                rate=$(awk -v d="$drained" -v m="$elapsed_min" 'BEGIN { printf "%.1f", d * 60 / m }')
                log "Average drain: ${rate}% per hour"
            fi
        fi
        echo -e "\n${GREEN}Monitoring stopped, summary written to $OUTPUT_FILE${NC}"
    fi
    exit 0
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
while getopts ":mn:t:o:sah" opt; do
    case "$opt" in
        m) INTERACTIVE=1 ;;
        n) INTERVAL_MIN="$OPTARG" ;;
        t) LOW_THRESHOLD="$OPTARG" ;;
        o) OUTPUT_FILE="$OPTARG" ;;
        s) SPEAK=1 ;;
        a) KEEP_AWAKE=1 ;;
        h) usage; exit 0 ;;
        :) die "Option -$OPTARG requires a value." ;;
        *) usage; exit 1 ;;
    esac
done

[ "$(uname -s)" = "Darwin" ] || die "This script only runs on macOS."
command -v pmset >/dev/null 2>&1 || die "pmset not found."
is_number "$INTERVAL_MIN" && [ "$INTERVAL_MIN" -gt 0 ] || die "Interval must be a positive number of minutes."
is_number "$LOW_THRESHOLD" || die "Threshold must be a number between 0 and 100."
is_number "$(battery_percentage)" || die "No battery found. Run this on a MacBook."

[ "$INTERACTIVE" -eq 1 ] && choose_scenario

mkdir -p "$(dirname "$OUTPUT_FILE")" || die "Cannot create $(dirname "$OUTPUT_FILE")"
touch "$OUTPUT_FILE" || die "Cannot write to $OUTPUT_FILE"

echo ""
printf "%55s\n" "🔋 BATTERY DRAIN MONITOR STARTED 🔋"
echo -e "\nFor results, open: $OUTPUT_FILE"
echo -e "Measuring every $INTERVAL_MIN minute(s)."
echo -e "\n${RED}${BOLD}Press Control-C to quit the script${NC}"

if [ "$(power_source)" = "AC Power" ]; then
    echo -e "\n${YELLOW}Warning: the Mac is connected to a charger, unplug it for a valid drain test.${NC}"
fi

if [ "$KEEP_AWAKE" -eq 1 ]; then
    caffeinate -i -w $$ &
    CAFFEINATE_PID=$!
fi

write_header
echo -e "\nResults file creation ✅"

trap finish INT TERM EXIT

START_EPOCH=$(date +%s)
START_PERCENT=$(battery_percentage)
count=1

while true; do
    percent=$(battery_percentage)
    timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    state=$(charge_state)

    if is_number "$percent"; then
        log "$count. $percent% @ $timestamp ($(power_source), $state)"
        echo -e "- $timestamp  Battery: $percent% ($state), file updated..."

        if [ "$percent" -lt "$LOW_THRESHOLD" ]; then
            log "   Battery percentage is below $LOW_THRESHOLD%"
            echo -e "  ${YELLOW}Battery percentage is below $LOW_THRESHOLD%${NC}"
        fi

        [ "$SPEAK" -eq 1 ] && say "Battery at $percent percent" &
    else
        log "$count. Could not read battery percentage @ $timestamp"
    fi

    count=$((count + 1))
    sleep $((INTERVAL_MIN * 60))
done
