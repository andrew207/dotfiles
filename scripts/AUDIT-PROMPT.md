# Host-side script audit prompt

Run this on **andrew-main** (the Arch host), not on the Mac. Paste the block below into the
local AI harness. It exists because the waybar config in this repo invokes ~16 helper scripts
that live only on the host — they came from the [JaKooLit](https://github.com/JaKooLit) dots
install and were never pulled into `dotfiles/`. Until we know which are actually used, we can't
decide whether to vendor them, leave them host-only, or prune the modules that call them.

Feed the answer back into the repo to decide the fate of `custom/weather`, `custom/cava_mviz`,
`custom/keyboard`, `custom/hint`, `custom/light_dark`, `custom/settings`, `custom/dot_update`,
`custom/menu`, `custom/lock` and `custom/power`.

---

```
Audit the Hyprland/waybar helper scripts on this machine. Read-only — do not modify, move or
delete anything. Report findings as a markdown table plus a short recommendation list.

Context: ~/dotfiles is a git repo that owns ~/.config/hypr and ~/.config/waybar via
~/dotfiles/apply.sh. The repo contains only three scripts (scripts/grimblast.sh,
scripts/record-script.sh, scripts/workspace_action.sh), but the waybar module definitions
reference many more that exist only on this host. I want to know which are real, which are
reachable, and what each one needs.

1. EXISTENCE
   For each path below, report: exists / missing, executable bit, size, and mtime.
     ~/.config/hypr/scripts/WaybarScripts.sh
     ~/.config/hypr/scripts/Volume.sh
     ~/.config/hypr/scripts/Kool_Quick_Settings.sh
     ~/.config/hypr/scripts/KeyHints.sh
     ~/.config/hypr/scripts/KeyBinds.sh
     ~/.config/hypr/scripts/KooLsDotsUpdate.sh
     ~/.config/hypr/scripts/SwitchKeyboardLayout.sh
     ~/.config/hypr/scripts/DarkLight.sh
     ~/.config/hypr/scripts/WaybarStyles.sh
     ~/.config/hypr/scripts/WaybarLayout.sh
     ~/.config/hypr/scripts/LockScreen.sh
     ~/.config/hypr/scripts/WaybarCava.sh
     ~/.config/hypr/scripts/Wlogout.sh
     ~/.config/hypr/scripts/ChangeBlur.sh
     ~/.config/hypr/scripts/Distro_update.sh
     ~/.config/hypr/UserScripts/WallpaperSelect.sh
     ~/.config/hypr/UserScripts/Weather.py
   Then list every OTHER file in ~/.config/hypr/scripts/ and ~/.config/hypr/UserScripts/ that
   I did not name above.

2. REACHABILITY
   Extract every script path the live waybar config actually calls:
     grep -ohE '\$HOME/\.config/hypr/(UserScripts|scripts)/[A-Za-z_0-9]+\.(sh|py)' \
       ~/.config/waybar/Modules ~/.config/waybar/Modules* ~/.config/waybar/UserModules \
       | sort -u
   Also grep ~/.config/hypr/*.lua and ~/.config/hypr/custom/*.lua for script references.
   Classify each script from step 1 as:
     - REACHABLE  (called by the live waybar or hypr config)
     - ORPHANED   (on disk, nothing calls it)
     - MISSING    (called, but not on disk -> a broken button in the bar)
   Note that ~/.config/waybar is the applied copy of ~/dotfiles/waybar, which was just pruned;
   if the two differ, say so and use the repo copy as the source of truth.

3. DEPENDENCIES
   For each REACHABLE script, list the external commands it shells out to (rough heuristic:
   first word of each command, minus shell builtins and its own functions). Cross-check each
   against `pacman -Q` / `command -v` and flag any that are NOT installed.
   Also check whether each script sources anything else under ~/.config/hypr — i.e. whether it
   is self-contained or depends on the wider JaKooLit tree (globalcontrol.sh, a themes dir,
   ~/.cache files, etc.).

4. SPECIFIC QUESTION: workspace_action.sh
   ~/dotfiles/scripts/workspace_action.sh is referenced by nothing in the repo, yet apply.sh
   installs it to ~/.config/hypr/scripts/. Search the whole host for callers — hypr config,
   waybar config, systemd units, shell rc files, other scripts, ~/.local/bin. Report whether
   it is dead. Do not delete it.

5. RECOMMENDATION
   For each script, recommend exactly one of:
     - VENDOR    — reachable and self-contained; copy into ~/dotfiles/scripts/ so the repo can
                   rebuild the bar on a fresh machine. Say how big the copy would be.
     - HOST-ONLY — reachable but depends on the JaKooLit install tree; too entangled to vendor.
                   Say what it depends on.
     - PRUNE     — orphaned or missing; the waybar module that calls it should be removed.
   Finish with a one-paragraph summary: how much of the bar would still work on a fresh machine
   that had only this repo, and what the cheapest path to "self-contained" is.
```
