#!/usr/bin/env bash
# Power/logout menu; ignore clicks while one is already open.
set -euo pipefail

pgrep -x wlogout >/dev/null || wlogout -p layer-shell
