#!/usr/bin/env bash
# Audio visualizer for the waybar custom/cava_mviz module: render cava's raw
# output as icon bars, one line per frame on stdout.
set -euo pipefail

sock="/tmp/cava-mviz-$UID.sock"
conf="$(mktemp)"

cat >"$conf" <<EOF
[general]
mode = raw
bars = 4
[output]
method = unix
socket_path = $sock
data_format = mono
EOF

rm -f "$sock"
cava -p "$conf" >/dev/null 2>&1 &
cava_pid=$!
trap 'kill "$cava_pid" 2>/dev/null; rm -f "$conf" "$sock"' EXIT
while ! [[ -S "$sock" ]]; do sleep 0.1; done

icons=(▁ ▂ ▄ ▆ █)
socat -u UNIX-CONNECT:"$sock" - |
while read -r v1 v2 v3 v4; do
    out=""
    for v in "$v1" "$v2" "$v3" "$v4"; do
        (( v > 999 )) && v=999
        out+="${icons[v * 5 / 1000]}"
    done
    printf '%s\n' "$out"
done
