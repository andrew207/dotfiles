#!/usr/bin/env bash
# Lock the screen: blank displays; if hyprlock already holds the session,
# keep it stopped while the displays sleep so it wakes on unlock.
set -euo pipefail

if pid=$(pidof hyprlock 2>/dev/null); then
    kill -STOP "$pid"
    trap 'kill -CONT "$pid" 2>/dev/null || true' EXIT
fi
hyprctl dispatch dpms off
