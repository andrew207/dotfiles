-- Hyprland config entry point.
-- See https://wiki.hypr.land/configuring/core/

require("env")
require("execs")
require("general")
require("colors")
require("rules")
require("keybinds")
require("monitors")

-- Machine-local overrides, not tracked in this repo. Absent is fine.
for _, m in ipairs({
    "custom.env",
    "custom.execs",
    "custom.general",
    "custom.rules",
    "custom.keybinds",
}) do
    pcall(require, m)
end
