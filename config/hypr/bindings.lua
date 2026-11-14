-- Keep only your personal keybinding overrides here. Add new bindings with
-- o.bind or replace defaults with o.rebind.

-- See current bindings and descriptions:
--   omarchy menu keybindings --print

-- To disable every Omarchy default binding, set this in
-- ~/.config/hypr/hyprland.lua before require("default.hypr.omarchy"), then add
-- only the bindings you want below:
--   omarchy_default_bindings = false

-- To disable all preinstalled app/webapp bindings, set:
--   omarchy_preinstalled_bindings = false

-- Add a new binding.
-- o.bind("SUPER + SHIFT + R", "SSH", "alacritty -e ssh your-server")

-- Change an existing binding. o.rebind takes the same arguments as o.bind.
-- This example replaces the default file manager with Flea.
-- o.rebind("SUPER + SHIFT + F", "File manager", { launch = "flea" })

-- Disable a default binding without replacing it.
-- hl.unbind("SUPER + SHIFT + B")

-- Logitech MX Keys examples:
-- o.bind("SUPER + H", nil, "voxtype record toggle")
-- o.bind("SUPER + PERIOD", nil, { panel = "omarchy.emojis" })

-- Outlook web app (replaces HEY defaults)
o.rebind("SUPER + SHIFT + E", "Email", { webapp = "https://outlook.office.com/mail/", focus = true })
o.rebind("SUPER + SHIFT + ALT + E", "New email", { webapp = "https://outlook.office.com/mail/deeplink/compose" })
o.rebind("SUPER + SHIFT + C", "Calendar", { webapp = "https://outlook.office.com/calendar/", focus = true })

-- Microsoft Teams web app
o.bind("SUPER + SHIFT + D", "Teams", { webapp = "https://teams.microsoft.com/", focus = true })

-- OpenStreetMap (replaces Google Maps)
o.rebind("SUPER + SHIFT + S", "OpenStreetMap", { webapp = "https://www.openstreetmap.org/", focus = true })
