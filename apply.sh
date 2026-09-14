#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DRY_RUN=0
WRITTEN=0
BACKUP_DIR="$HOME/.config/dotfiles.pre-sync-$(date -u +%Y%m%dT%H%M%SZ)"
# Set by each apply_* function; helpers below resolve paths against them.
SRC_ROOT="$ROOT/hypr"
DEST_ROOT="$HOME/.config/hypr"

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

check_config() {
    # $1 = binary, $2 = repo config to validate before installing it.
    # No-op when the binary is absent or too old to know --check-config, so this
    # can never block an apply on its own account.
    local bin="$1" file="$2"
    command -v "$bin" >/dev/null 2>&1 || return 0
    "$bin" --help 2>&1 | grep -q -- --check-config || return 0
    if ! "$bin" --check-config --config="$file"; then
        echo "error: $bin rejected $file; not installing it" >&2
        exit 1
    fi
}

backup_path() {
    # $1 = path under $DEST_ROOT to relocate into the timestamped backup dir
    local rel="$1" src dest
    src="$DEST_ROOT/$rel"
    dest="$BACKUP_DIR/$rel"
    if [[ ! -e "$src" && ! -L "$src" ]]; then
        return 0
    fi
    if [[ $DRY_RUN -eq 1 ]]; then
        log "[dry-run] move $src -> $dest"
    else
        mkdir -p "$(dirname "$dest")"
        mv "$src" "$dest"
        log "moved    $src -> $dest"
        WRITTEN=$((WRITTEN + 1))
    fi
}

copy_file() {
    # $1 = dest path under $DEST_ROOT, $2 = mode ("644"|"755"),
    # $3 = source path under $ROOT (defaults to $SRC_ROOT/$1)
    local rel="$1" mode="${2:-644}" src="${3:-$SRC_ROOT/$1}" dest
    dest="$DEST_ROOT/$rel"
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

install_link() {
    # $1 = path under $DEST_ROOT that must be a symlink to $DEST_ROOT/$2
    local rel="$1" target="$DEST_ROOT/$2" dest="$DEST_ROOT/$1"
    if [[ -L "$dest" && "$(readlink "$dest")" == "$target" ]]; then
        return 0
    fi
    if [[ -e "$dest" || -L "$dest" ]]; then
        backup_path "$rel"
    fi
    if [[ $DRY_RUN -eq 1 ]]; then
        log "[dry-run] link   $dest -> $target"
    else
        mkdir -p "$(dirname "$dest")"
        ln -sfn "$target" "$dest"
        log "linked   $dest -> $target"
    fi
    WRITTEN=$((WRITTEN + 1))
}

keep_only() {
    # Move every entry of $DEST_ROOT/$1/ not listed in "${@:2}" into the backup dir.
    local dir="$1" entry name
    shift
    local reset_nullglob=0
    shopt -q nullglob || reset_nullglob=1
    shopt -s nullglob
    for entry in "$DEST_ROOT/$dir"/*; do
        [[ -d "$entry" ]] && continue
        name="$(basename "$entry")"
        local kept keep=0
        for kept in "$@"; do
            [[ "$name" == "$kept" ]] && keep=1 && break
        done
        [[ $keep -eq 1 ]] || backup_path "$dir/$name"
    done
    [[ $reset_nullglob -eq 1 ]] && shopt -u nullglob
    return 0
}

apply_hyprland() {
    SRC_ROOT="$ROOT/hypr"
    DEST_ROOT="$HOME/.config/hypr"
    local files=(
        hyprland.conf hyprland.lua env.lua execs.lua general.lua colors.lua
        rules.lua keybinds.lua monitors.lua
        hypridle.conf hyprlock.conf
    )
    local f
    for f in "${files[@]}"; do
        copy_file "$f" 644
    done
    # nullglob so an empty hyprlock/ doesn't pass the literal pattern to install.
    local reset_nullglob=0
    shopt -q nullglob || reset_nullglob=1
    shopt -s nullglob
    for f in "$SRC_ROOT"/hyprlock/*.sh; do
        copy_file "hyprlock/${f##*/}" 755
    done
    # Helper scripts live at repo root but install under ~/.config/hypr/scripts,
    # which is the path keybinds.lua invokes them by.
    for f in "$ROOT"/scripts/*.sh "$ROOT"/scripts/*.py; do
        copy_file "scripts/${f##*/}" 755 "$ROOT/scripts/${f##*/}"
    done
    [[ $reset_nullglob -eq 1 ]] && shopt -u nullglob

    # Legacy hyprlang layout -> backup dir (only if present).
    backup_path hyprland
    backup_path custom/env.conf
    backup_path custom/execs.conf
    backup_path custom/general.conf
    backup_path custom/keybinds.conf
    backup_path custom/rules.conf
    backup_path monitors.conf
    backup_path workspaces.conf
    backup_path shaders
    backup_path custom/scripts/__restore_video_wallpaper.sh
    backup_path hyprland.conf.old
    backup_path hypridle.conf.new
    backup_path hyprlock.conf.new
    backup_path hyprland/keybinds.conf.bak
}

apply_foot() {
    SRC_ROOT="$ROOT/foot"
    DEST_ROOT="$HOME/.config/foot"
    check_config foot "$SRC_ROOT/foot.ini"
    copy_file foot.ini 644
}

apply_fuzzel() {
    SRC_ROOT="$ROOT/fuzzel"
    DEST_ROOT="$HOME/.config/fuzzel"
    check_config fuzzel "$SRC_ROOT/fuzzel.ini"
    copy_file fuzzel.ini 644
}

apply_waybar() {
    SRC_ROOT="$ROOT/waybar"
    DEST_ROOT="$HOME/.config/waybar"
    copy_file "configs/[TOP] Default" 644
    copy_file "style/[Extra] Modern-Combined - Transparent.css" 644
    copy_file "style/catppuccin-themes/latte.css" 644
    local f
    for f in Modules ModulesCustom ModulesGroups ModulesWorkspaces UserModules; do
        copy_file "$f" 644
    done
    copy_file "wallust/colors-waybar.css" 644
    install_link config "configs/[TOP] Default"
    install_link style.css "style/[Extra] Modern-Combined - Transparent.css"

    # Pruned pack presets/variants on disk -> backup dir.
    backup_path ModulesVertical
    keep_only configs "[TOP] Default"
    keep_only style "[Extra] Modern-Combined - Transparent.css"
    keep_only style/catppuccin-themes latte.css
}

COMPONENTS=(hyprland foot fuzzel waybar)

for component in "${COMPONENTS[@]}"; do
    "apply_${component}"
done

if pgrep -x waybar >/dev/null 2>&1; then
    if [[ $DRY_RUN -eq 1 ]]; then
        log "[dry-run] would run pkill -USR2 -x waybar (reload config+style)"
    else
        pkill -USR2 -x waybar
        log "reloaded waybar (SIGUSR2)"
    fi
fi
log "note: foot/fuzzel changes only affect newly launched instances."
log "note: pacman-q is a package manifest, not config; apply.sh does not install it."

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
