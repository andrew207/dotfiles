---- Basics ----

-- terminal
hl.bind("SUPER + Return", hl.dsp.exec_cmd("foot"))
-- start menu / drun. Bare keysym: with a keysym the keys are no longer
-- treated as modifiers, so "SUPER + Super_L" would depend on press order.
hl.bind("SUPER_L", hl.dsp.exec_cmd("pkill rofi || rofi -show drun"))
-- clipboard history
hl.bind("SUPER + V", hl.dsp.exec_cmd(
    [[pkill fuzzel || cliphist list | fuzzel --match-mode fzf --dmenu | cliphist decode | wl-copy]]))
-- Screen snip >> edit
hl.bind("SUPER + SHIFT + ALT + S", hl.dsp.exec_cmd([[grim -g "$(slurp)" - | swappy -f -]]))
-- Screen snip >> OCR >> clipboard
hl.bind("SUPER + SHIFT + T", hl.dsp.exec_cmd(
    [[grim -g "$(slurp $SLURP_ARGS)" "tmp.png" && tesseract -l eng "tmp.png" - | wl-copy && rm "tmp.png"]]))
-- Screen snip >> Save >> clipboard
hl.bind("Print", hl.dsp.exec_cmd(
    [[mkdir -p ~/Pictures/Screenshots && ~/.config/hypr/scripts/grimblast.sh copysave screen ~/Pictures/Screenshots/Screenshot_"$(date '+%Y-%m-%d_%H.%M.%S')".png]]),
    { locked = true })
-- Screen recording (toggle: same bind stops an in-progress recording).
-- Saves to the XDG videos dir. ALT variant also captures desktop audio.
hl.bind("SUPER + SHIFT + R", hl.dsp.exec_cmd("~/.config/hypr/scripts/record-script.sh"))
hl.bind("SUPER + SHIFT + ALT + R", hl.dsp.exec_cmd("~/.config/hypr/scripts/record-script.sh --sound"))
-- Lock
hl.bind("SUPER + L", hl.dsp.exec_cmd("loginctl lock-session"))
-- kill
hl.bind("SUPER + Q", hl.dsp.window.close())

---- Window arrangement ----

hl.bind("SUPER + SHIFT + Left", hl.dsp.window.move({ direction = "left" }))
hl.bind("SUPER + SHIFT + Right", hl.dsp.window.move({ direction = "right" }))
hl.bind("SUPER + SHIFT + Up", hl.dsp.window.move({ direction = "up" }))
hl.bind("SUPER + SHIFT + Down", hl.dsp.window.move({ direction = "down" }))
hl.bind("SUPER + F", hl.dsp.window.fullscreen({ mode = "fullscreen" }))
-- fullscreen but keep waybar visible
hl.bind("SUPER + D", hl.dsp.window.fullscreen({ mode = "maximized" }))

---- Workspaces ----

-- Ctrl+Alt = navigate l/r between workspaces
hl.bind("CTRL + ALT + Right", hl.dsp.focus({ workspace = "r+1" }))
hl.bind("CTRL + ALT + Left", hl.dsp.focus({ workspace = "r-1" }))

-- super+n = jump to workspace
for i = 1, 9 do
    hl.bind("SUPER + " .. i, hl.dsp.focus({ workspace = i }))
end

-- Super+Shift = shift windows between workspaces
hl.bind("CTRL + SUPER + SHIFT + Right", hl.dsp.window.move({ workspace = "r+1" }))
hl.bind("CTRL + SUPER + SHIFT + Left", hl.dsp.window.move({ workspace = "r-1" }))

for i = 1, 9 do
    hl.bind("SUPER + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
end

---- alt-tab ----

hl.bind("ALT + Tab", function()
    hl.dispatch(hl.dsp.window.cycle_next())
    hl.dispatch(hl.dsp.window.alter_zorder({ mode = "top" }))
end)

---- hot reload ----
--hl.bind("CTRL + SUPER + ALT + R", hl.dsp.reload_config(), { release = true })

---- Media ----

local next_track = [[playerctl next || playerctl position `bc <<< "100 * $(playerctl metadata mpris:length) / 1000000 / 100"`]]

hl.bind("SUPER + SHIFT + N", hl.dsp.exec_cmd(next_track), { locked = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd(next_track), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })
hl.bind("SUPER + SHIFT + ALT + mouse:275", hl.dsp.exec_cmd("playerctl previous"))
hl.bind("SUPER + SHIFT + ALT + mouse:276", hl.dsp.exec_cmd(next_track))
hl.bind("SUPER + SHIFT + B", hl.dsp.exec_cmd("playerctl previous"), { locked = true })
hl.bind("SUPER + SHIFT + P", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })

-- audio
hl.bind("ALT + XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_SOURCE@ toggle"), { locked = true })
hl.bind("SUPER + XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_SOURCE@ toggle"), { locked = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 0%"), { locked = true })
hl.bind("SUPER + SHIFT + M", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 0%"), { locked = true })
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),
    { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
    { locked = true, repeating = true })

---- Execs ----

-- editors
hl.bind("SUPER + C", hl.dsp.exec_cmd("code"))
hl.bind("SUPER + ALT + C", hl.dsp.exec_cmd("mousepad"))

-- file managers
hl.bind("SUPER + E", hl.dsp.exec_cmd("nautilus --new-window"))
hl.bind("SUPER + ALT + E", hl.dsp.exec_cmd("thunar"))

-- Web browsers
hl.bind("SUPER + W", hl.dsp.exec_cmd("firefox"))
hl.bind("SUPER + ALT + W", hl.dsp.exec_cmd("google-chrome-stable"))
