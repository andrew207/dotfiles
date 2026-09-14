#!/usr/bin/env bash
# Volume/mute control for the waybar audio modules.
set -euo pipefail

step=5%

case "${1:-}" in
    --inc)       pactl set-sink-volume @DEFAULT_SINK@ +"$step" ;;
    --dec)       pactl set-sink-volume @DEFAULT_SINK@ -"$step" ;;
    --toggle)    pactl set-sink-mute @DEFAULT_SINK@ toggle ;;
    --mic-inc)   pactl set-source-volume @DEFAULT_SOURCE@ +"$step" ;;
    --mic-dec)   pactl set-source-volume @DEFAULT_SOURCE@ -"$step" ;;
    --toggle-mic) pactl set-source-mute @DEFAULT_SOURCE@ toggle ;;
    *) echo "usage: ${0##*/} {--inc|--dec|--toggle|--mic-inc|--mic-dec|--toggle-mic}" >&2; exit 1 ;;
esac
