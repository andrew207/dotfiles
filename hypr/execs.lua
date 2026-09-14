hl.on("hyprland.start", function()
    -- Bar
    hl.exec_cmd("waybar")

    -- Core components (authentication, lock screen, notification daemon)
    hl.exec_cmd("gnome-keyring-daemon --start --components=secrets")
    hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 || /usr/libexec/polkit-gnome-authentication-agent-1")
    -- Notification daemon. waybar's custom/swaync module (group/notify) talks to
    -- this; without it the bell renders but never shows anything.
    hl.exec_cmd("swaync")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("dbus-update-activation-environment --all")
    hl.exec_cmd("hyprpm reload")

    -- Audio
    -- hl.exec_cmd("easyeffects --gapplication-service")

    -- Clipboard: history
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")

    -- Cursor
    hl.exec_cmd("hyprctl setcursor Bibata-Modern-Classic 24")
end)

-- Overview. Guarded so a missing/unbuilt plugin doesn't kill this module.
if hl.plugin.hyprexpo ~= nil then
    hl.config({
        plugin = {
            hyprexpo = {
                columns = 3,
                gap_size = 5,
                bg_col = "rgb(000000)",
                -- [center/first] [workspace] e.g. "first 1" or "center m+1"
                workspace_method = "center current",
            },
        },
    })
end
