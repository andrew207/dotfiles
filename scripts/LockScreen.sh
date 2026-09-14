#!/usr/bin/env bash
# Lock the screen: blank displays; if hyprlock already holds the session,
# keep it stopped while the displays sleep so it wakes on unlock.
set -euo pipefail

if pid=$(pidof hyprlock 2>/dev/null); then
    kill -STOP "$pid"
    trap 'kill -CONT "$pid" 2>/dev/null || true' EXIT
fi
# Lua config: the dispatch payload is evaluated as Lua, so the legacy
# `hyprctl dispatch dpms off` no longer parses. exec_raw takes the old text.
hyprctl dispatch 'hl.dsp.exec_raw("dpms off")'
