#!/usr/bin/env bash

declare -A icons=([brave]="󰝚" [mpv]="󰐹" [firefox]="󰈹")
sep=$'\x1f'

esc() {
    local s=${1//&/&amp;}
    s=${s//</&lt;}
    printf '%s' "${s//>/&gt;}"
}

active_player() {
    busctl --user get-property org.mpris.MediaPlayer2.playerctld /org/mpris/MediaPlayer2 \
        com.github.altdesktop.playerctld PlayerNames 2>/dev/null |
        grep -oE 'MediaPlayer2\.[^.\" ]+' | head -1 | cut -d. -f2
}

while true; do
    playerctl -p playerctld --follow metadata \
        --format "{{status}}${sep}{{title}}${sep}{{artist}}" 2>/dev/null |
    while IFS=$sep read -r status title artist; do
        if [[ $status == Stopped || -z $title ]]; then
            echo '{"text": ""}'
            continue
        fi
        player=$(active_player)
        icon=${icons[$player]:-󰎇}
        [[ $status == Paused ]] && icon=󰏤
        text=$title
        [[ -n $artist ]] && text="$title — $artist"
        (( ${#text} > 30 )) && text="${text:0:29}…"
        tooltip="$(esc "${player:-media}: $title")"$'\n'"$(esc "$artist")"
        jq -nc --arg t "$icon  $(esc "$text")" --arg tt "$tooltip" --arg c "${status,,}" \
            '{text: $t, tooltip: $tt, class: $c}'
    done
    echo '{"text": ""}'
    sleep 1
done
