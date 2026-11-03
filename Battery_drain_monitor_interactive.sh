#!/bin/bash
# ©copyright Jan Vancoppenolle, Timelord Enterprises
#
# Interactive version of the Battery Drain Monitor: shows the scenario menu
# (idle / 4K stream) before monitoring starts. All logic lives in
# Battery_drain_monitor.sh; extra options are passed through (see -h).

exec "$(dirname "$0")/Battery_drain_monitor.sh" -m "$@"
