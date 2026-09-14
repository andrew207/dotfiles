-- Regexes use [[long brackets]] so backslashes stay literal.
-- Effects are processed top to bottom; the LAST match wins.

-- Disable blur for XWayland windows (or context menus with shadow would look weird)
hl.window_rule({ match = { xwayland = true }, no_blur = true })

-- Floating
for _, class in ipairs({
    [[^(steam)$]],
    [[^(proton)$]],
    [[^(pavucontrol)$]],
    [[^(org.pulseaudio.pavucontrol)$]],
    [[^(nm-connection-editor)$]],
    [[^(peek)$]],
}) do
    hl.window_rule({ match = { class = class }, float = true })
end

-- Tiling
hl.window_rule({ match = { class = [[^dev\.warp\.Warp$]] }, tile = true })

-- Picture-in-Picture
hl.window_rule({
    match = { title = [[^([Pp]icture[-\s]?[Ii]n[-\s]?[Pp]icture)(.*)$]] },
    float = true,
    pin = true,
    keep_aspect_ratio = true,
    move = { "monitor_w*0.73", "monitor_h*0.72" },
    size = { "monitor_w*0.25", "monitor_h*0.25" },
})

-- Dialog windows - float + center these.
for _, title in ipairs({
    [[^(Open File)(.*)$]],
    [[^(Select a File)(.*)$]],
    [[^(Choose wallpaper)(.*)$]],
    [[^(Open Folder)(.*)$]],
    [[^(Save As)(.*)$]],
    [[^(Library)(.*)$]],
    [[^(File Upload)(.*)$]],
}) do
    hl.window_rule({ match = { title = title }, float = true, center = true })
end

-- steam
hl.window_rule({ match = { title = [[.*\.exe]] }, immediate = true })
hl.window_rule({ match = { class = [[^(steam_app)]] }, immediate = true })

-- No shadow for tiled windows. Keep last: last match wins.
hl.window_rule({ match = { float = false }, no_shadow = true })
