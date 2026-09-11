# apply.sh + hyprland config cleanup

## Context

- Installed: `hyprland-0.56.2-2`, `hypridle-0.1.8`, `hyprlock-0.9.6`, `waybar`, `fuzzel`, `foot` (see `/var/lib/pacman/local`).
- The repo's `hypr/` config is **already migrated** to Lua (commit `bcfb1cf`); `hypridle`/`hyprlock` still read hyprlang, so they stay `.conf`.
- The live system (`~/.config/hypr`) is still the old hyprlang layout: `hyprland.conf` sourcing `hyprland/*.conf`, plus `custom/*.conf`, `monitors.conf`, `workspaces.conf`, `shaders/`, and `*.old` / `*.new` / `*.bak` leftovers.
- Confirmed by inspection: `hyprlock.conf` sources `hyprlock/check-capslock.sh` and `hyprlock/status.sh` **today**, so both scripts are in use and must be tracked. `general.lua:73` `screen_shader` is commented out, so `shaders/*.frag` is unused → not tracked.
- Decided: dropped settings from the migration (`debug:full_cm_proto`, `ILLOGICAL_IMPULSE_VIRTUAL_ENV`, `Super+Z`, `Super+Alt+F`, `Ctrl+Super+V`, `Super+X` mousepad) are **intentional**; do not re-add.

## Task 1 — fix the repo config (do this before apply.sh)

1. `git mv hypr/hyprindle.conf hypr/hypridle.conf` (filename was misspelled).
2. In that file, close the first `listener` block: `timeout = 600` / `on-timeout = loginctl lock-session` currently has no `}` before the `# Turn off screen` listener, so the 660/3600 listeners nest inside it. Add the missing `}`.
3. Add the two in-use lock-screen scripts to the repo, executable (755), at:
   - `hypr/hyprlock/check-capslock.sh` (content = `~/.config/hypr/hyprlock/check-capslock.sh`)
   - `hypr/hyprlock/status.sh` (content = `~/.config/hypr/hyprlock/status.sh`)
   `hyprlock.conf:32,83` reference them at `${XDG_CONFIG_HOME:-$HOME/.config}/hypr/hyprlock/...`, so a fresh machine is broken without them.
4. Do **not** add `shaders/`. Do **not** add `custom/*.lua` stubs — `hyprland.lua:13-21` already `pcall(require, ...)`s them and "absent is fine".

## Task 2 — write `apply.sh` (repo root)

Bash, `#!/usr/bin/env bash`, `set -euo pipefail`, `ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"`.

- `COMPONENTS=(hyprland)` for now; anything else (`foot`, `fuzzel`, `waybar`, `pacman-q`) is TODO and prints a skip note. Entry point loops components and calls `apply_<component>`.
- `apply_hyprland()` copies (no symlinks) `hypr/**` → `$HOME/.config/hypr/` preserving relative layout:
  - `hyprland.lua`, `env.lua`, `execs.lua`, `general.lua`, `colors.lua`, `rules.lua`, `keybinds.lua`, `monitors.lua` → `~/.config/hypr/`
  - `hypridle.conf`, `hyprlock.conf` → `~/.config/hypr/`
  - `hyprlock/*.sh` → `~/.config/hypr/hyprlock/`, mode 755
- Idempotent: `cmp -s` source vs target; skip when identical, print one line per file actually written.
- Conflict handling: if a target exists and differs, `mv` it into `$HOME/.config/hypr.pre-lua-<UTC-%Y%m%dT%H%M%SZ>/` preserving relative path, then copy. Never overwrite silently, never delete.
- Legacy cleanup (move into the same timestamped backup dir, only if present): `hyprland.conf`, `hyprland/`, `custom/*.conf`, `monitors.conf`, `workspaces.conf`, `hyprland.conf.old`, `hypridle.conf.new`, `hyprlock.conf.new`, `hyprland/keybinds.conf.bak`. Leave `custom/` itself and `custom/scripts/` in place.
- Reload: if `[ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]` run `hyprctl reload` and report its output; otherwise print `run hyprctl reload (or re-login) to apply`.
- Flags: `--dry-run` (print planned moves/copies, touch nothing), `-h/--help`. Non-zero exit on any copy failure.

## Task 3 — validation

- `bash -n apply.sh`; `shellcheck apply.sh` if available.
- `./apply.sh --dry-run` → expected moves for the legacy list above, no writes.
- `./apply.sh` → `ls -la ~/.config/hypr` shows the 8 `.lua` files + `hypridle.conf`, `hyprlock.conf`, `hyprlock/*.sh` (exec bit set); legacy `.conf`/`custom/*.conf` gone; exactly one `~/.config/hypr.pre-lua-*` dir.
- Re-run `./apply.sh` → "0 files changed" (idempotency).
- `grep -n '^}' hypr/hypridle.conf` shows 4 balanced blocks; with a running session, `hyprctl reload` reports no config parse errors and `loginctl lock-session` still renders the clock/date/status labels (scripts resolve).

## Risks / caveats

- Copy-based install means later repo edits do nothing until `apply.sh` runs again; the script prints that hint on reload.
- If hyprland 0.56 also auto-loads a stray `hyprland.conf`, leaving it behind would shadow the Lua entry point — the legacy move in Task 2 covers this; verify after the real run.
- `hyprctl reload` cannot re-run everything an initial boot does (e.g. `dbus-update-activation-environment`); a full re-login is still the reference test.
