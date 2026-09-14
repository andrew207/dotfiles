#!/usr/bin/env python3
"""Current weather for the waybar custom/weather module (JSON lines to stdout)."""
import json
import subprocess
import sys


def main() -> None:
    raw = subprocess.run(
        ["curl", "-fs", "--max-time", "10", "wttr.in/Canberra?format=j1"],
        capture_output=True, text=True, check=True,
    ).stdout
    cur = json.loads(raw)["current_condition"][0]
    print(json.dumps({
        "text": f'{cur["temp_C"]}° {cur["weatherDesc"][0]["value"].lower()}',
        "alt": f'feels {cur["FeelsLikeC"]}°C, hum {cur["humidity"]}%',
    }))


if __name__ == "__main__":
    try:
        main()
    except Exception:
        sys.exit(1)
