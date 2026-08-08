#!/usr/bin/env bash

set -euo pipefail

sensor=""
for hw in /sys/class/hwmon/hwmon*; do
    [[ -r "$hw/name" ]] || continue
    case "$(<"$hw/name")" in
        coretemp | k10temp | zenpower)
            sensor="$hw"
            break
            ;;
    esac
done

if [[ -z "$sensor" ]]; then
    for hw in /sys/class/hwmon/hwmon*; do
        [[ -r "$hw/name" ]] || continue
        if [[ "$(<"$hw/name")" == acpitz* ]]; then
            sensor="$hw"
            break
        fi
    done
fi

if [[ -z "$sensor" || ! -r "$sensor/temp1_input" ]]; then
    printf '{"text":"󰔏 n/a","tooltip":"No CPU temperature sensor found","class":"unknown"}\n'
    exit 0
fi

milli=$(<"$sensor/temp1_input")
deg=$((milli / 1000))
label=$(<"$sensor/name")

if   (( deg >= 85 )); then class="critical"
elif (( deg >= 70 )); then class="warning"
else                       class="normal"
fi

printf '{"text":"󰔏 %d°C","tooltip":"%s: %d°C","class":"%s"}\n' \
    "$deg" "$label" "$deg" "$class"
