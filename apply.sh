#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DRY_RUN=0
WRITTEN=0
BACKUP_DIR="$HOME/.config/hypr.pre-lua-$(date -u +%Y%m%dT%H%M%SZ)"

usage() {
    cat <<EOF
Usage: ${0##*/} [options]

Apply repo dotfiles to \$HOME/.config.

Options:
  -n, --dry-run   Print planned moves/copies without touching anything
  -h, --help      Show this help
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        -n|--dry-run) DRY_RUN=1; shift ;;
        -h|--help) usage; exit 0 ;;
        *) echo "unknown option: $1" >&2; usage >&2; exit 1 ;;
    esac
done

log() { printf '%s\n' "$*"; }

backup_path() {
    # $1 = path under $HOME/.config to relocate into the timestamped backup dir
    local rel="$1" src dest
    src="$HOME/.config/hypr/$rel"
    dest="$BACKUP_DIR/$rel"
    if [[ ! -e "$src" ]]; then
        return 0
    fi
    if [[ $DRY_RUN -eq 1 ]]; then
        log "[dry-run] move $src -> $dest"
    else
        mkdir -p "$(dirname "$dest")"
        mv "$src" "$dest"
        log "moved    $src -> $dest"
    fi
}

copy_file() {
    # $1 = dest path under ~/.config/hypr, $2 = mode ("644"|"755"),
    # $3 = source path under $ROOT (defaults to hypr/$1)
    local rel="$1" mode="${2:-644}" src="$ROOT/${3:-hypr/$1}" dest
    dest="$HOME/.config/hypr/$rel"
    if [[ -f "$dest" ]] && cmp -s "$src" "$dest"; then
        return 0
    fi
    if [[ $DRY_RUN -eq 1 ]]; then
        if [[ -f "$dest" ]]; then
            log "[dry-run] replace $dest (differs; old copy -> $BACKUP_DIR/$rel)"
        else
            log "[dry-run] copy   $src -> $dest (mode $mode)"
        fi
    else
        if [[ -f "$dest" ]]; then
            mkdir -p "$(dirname "$BACKUP_DIR/$rel")"
            mv "$dest" "$BACKUP_DIR/$rel"
            log "moved    $dest -> $BACKUP_DIR/$rel"
        fi
        mkdir -p "$(dirname "$dest")"
        install -m "$mode" "$src" "$dest"
        log "wrote    $dest"
    fi
    WRITTEN=$((WRITTEN + 1))
}

apply_hyprland() {
    local files=(
        hyprland.lua env.lua execs.lua general.lua colors.lua
        rules.lua keybinds.lua monitors.lua
        hypridle.conf hyprlock.conf
    )
    local f rel
    for f in "${files[@]}"; do
        copy_file "$f" 644
    done
    # nullglob so an empty hyprlock/ doesn't pass the literal pattern to install.
    local reset_nullglob=0
    shopt -q nullglob || reset_nullglob=1
    shopt -s nullglob
    for f in "$ROOT"/hypr/hyprlock/*.sh; do
        copy_file "hyprlock/${f##*/}" 755
    done
    # Helper scripts live at repo root but install under ~/.config/hypr/scripts,
    # which is the path keybinds.lua invokes them by.
    for f in "$ROOT"/scripts/*.sh; do
        copy_file "scripts/${f##*/}" 755 "scripts/${f##*/}"
    done
    [[ $reset_nullglob -eq 1 ]] && shopt -u nullglob

    # Legacy hyprlang layout -> backup dir (only if present).
    backup_path hyprland.conf
    backup_path hyprland
    backup_path custom/env.conf
    backup_path custom/execs.conf
    backup_path custom/general.conf
    backup_path custom/keybinds.conf
    backup_path custom/rules.conf
    backup_path monitors.conf
    backup_path workspaces.conf
    backup_path hyprland.conf.old
    backup_path hypridle.conf.new
    backup_path hyprlock.conf.new
    backup_path hyprland/keybinds.conf.bak
}

COMPONENTS=(hyprland)

for component in "${COMPONENTS[@]}"; do
    "apply_${component}"
done
# TODO: foot, fuzzel, waybar, pacman-q
for skipped in foot fuzzel waybar pacman-q; do
    log "skipped  $skipped (not implemented yet)"
done

if [[ $DRY_RUN -eq 0 && $WRITTEN -gt 0 && -d "$BACKUP_DIR" ]]; then
    log "backups  $BACKUP_DIR"
fi

if [[ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]]; then
    if [[ $DRY_RUN -eq 1 ]]; then
        log "[dry-run] would run hyprctl reload"
    else
        log "$(hyprctl reload 2>&1)"
        log "note: edits to the repo only take effect after running apply.sh again."
    fi
else
    log "run hyprctl reload (or re-login) to apply"
fi

log "done: $WRITTEN file(s) changed"
exit 0
