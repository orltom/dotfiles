-- Hyprland config, converted from hyprland.conf (hyprlang -> lua).
-- See https://wiki.hypr.land/Configuring/Start/

-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

hl.env("AQ_DRM_DEVICES", "/dev/dri/card1")
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")


------------------
---- INCLUDES ----
------------------

-- Paths are relative to hyprland.lua, and each require() gets its own scope,
-- so an error in one of these will not kill the rest of this file.
require("monitor-mobile")
require("workspaces")


---------------------
---- MY PROGRAMS ----
---------------------

local mainMod     = "SUPER"
local alt         = "ALT"

local terminal    = "kitty"
local fileManager = "thunar"
local menu        = "wofi --show drun"


-------------------
---- AUTOSTART ----
-------------------

hl.on("hyprland.start", function()
    -- Bring up the systemd graphical session so xdg-desktop-portal can start.
    -- The portal unit has Requisite=graphical-session.target; without this,
    -- screen sharing (Chromium/Teams/etc.) fails because the portal never starts.
    hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP HYPRLAND_INSTANCE_SIGNATURE")
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP HYPRLAND_INSTANCE_SIGNATURE")
    hl.exec_cmd("systemctl --user start hyprland-session.target")
    hl.exec_cmd("~/.config/hypr/monitor-listener.sh")
    hl.exec_cmd("~/.config/hypr/screen.sh")
    hl.exec_cmd("sleep 1 && waybar")
    hl.exec_cmd("mako")
    hl.exec_cmd("clipse -listen")
    hl.exec_cmd("sleep 2 && /usr/bin/1password")
    hl.exec_cmd("/usr/bin/jetbrains-toolbox")
    hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")
end)


-----------------------
---- LOOK AND FEEL ----
-----------------------

hl.config({
    misc = {
        disable_hyprland_logo    = true,
        disable_splash_rendering = true,
        force_default_wallpaper  = 0,
        background_color         = "rgb(49, 58, 73)",
    },

    general = {
        border_size = 1,
        gaps_in     = 2,
        -- was `gaps_out = 5,2,5,2` (CSS order: top, right, bottom, left)
        gaps_out    = { top = 5, right = 2, bottom = 5, left = 2 },

        col = {
            active_border   = { colors = { "rgba(33ccffee)", "rgba(00ff99ee)" }, angle = 45 },
            inactive_border = "rgba(595959aa)",
        },

        resize_on_border = false,
        allow_tearing    = false,
        layout           = "dwindle",
    },

    decoration = {
        rounding         = 10,
        rounding_power   = 2,
        active_opacity   = 1.0,
        inactive_opacity = 1.0,

        shadow = {
            enabled      = true,
            range        = 4,
            render_power = 3,
            color        = "rgba(1a1a1aee)",
        },

        blur = {
            enabled        = true,
            size           = 3,
            passes         = 3,
            vibrancy       = 0.18,
            ignore_opacity = false,
        },
    },

    animations = {
        enabled = true,
    },

    input = {
        kb_layout    = "us,ch",
        kb_variant   = "altgr-intl,de",
        follow_mouse = 1,
        sensitivity  = 0,

        touchpad = {
            natural_scroll = false,
        },
    },

    cursor = {
        no_hardware_cursors = true,
    },
})

hl.device({
    name        = "epic-mouse-v1",
    sensitivity = -0.5,
})

hl.gesture({
    fingers   = 3,
    direction = "horizontal",
    action    = "workspace",
})


--------------------
---- ANIMATIONS ----
--------------------

hl.curve("easeOutQuint",   { type = "bezier", points = { {0.23, 1},    {0.32, 1}  } })
hl.curve("easeInOutCubic", { type = "bezier", points = { {0.65, 0.05}, {0.36, 1}  } })
hl.curve("linear",         { type = "bezier", points = { {0, 0},       {1, 1}     } })
hl.curve("almostLinear",   { type = "bezier", points = { {0.5, 0.5},   {0.75, 1}  } })
hl.curve("quick",          { type = "bezier", points = { {0.15, 0},    {0.1, 1}   } })

hl.animation({ leaf = "global",        enabled = true, speed = 10,   bezier = "default" })
hl.animation({ leaf = "border",        enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows",       enabled = true, speed = 4.79, bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn",     enabled = true, speed = 4.1,  bezier = "easeOutQuint", style = "popin 87%" })
hl.animation({ leaf = "windowsOut",    enabled = true, speed = 1.49, bezier = "linear",       style = "popin 87%" })
hl.animation({ leaf = "fadeIn",        enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut",       enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade",          enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers",        enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn",      enabled = true, speed = 4,    bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut",     enabled = true, speed = 1.5,  bezier = "linear",       style = "fade" })
hl.animation({ leaf = "fadeLayersIn",  enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces",    enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesIn",  enabled = true, speed = 1.21, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "zoomFactor",    enabled = true, speed = 7,    bezier = "quick" })


---------------------
---- KEYBINDINGS ----
---------------------

-- Move / resize with the mouse
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- reload / exit
hl.bind(mainMod .. " + SHIFT + R", hl.dsp.exec_cmd("hyprctl reload"))
hl.bind(mainMod .. " + Q",         hl.dsp.exit())
hl.bind(mainMod .. " + F12",       hl.dsp.exec_cmd("~/.config/hypr/screen.sh"))

-- Terminal / launcher / misc
hl.bind(mainMod .. " + return", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + D",      hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + K",      hl.dsp.exec_cmd("hyprctl switchxkblayout all next"))
hl.bind(mainMod .. " + L",      hl.dsp.exec_cmd("hyprlock"))
hl.bind(mainMod .. " + E",      hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + V",      hl.dsp.exec_cmd(terminal .. " --class clipse -e 'clipse'"))

-- Kill focused window
hl.bind(mainMod .. " + C", hl.dsp.window.close())
hl.bind(alt .. " + F4",    hl.dsp.window.close())

-- Focus movement (directional)
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "l" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "d" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "u" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "r" }))

-- Move window
hl.bind(mainMod .. " + SHIFT + left",  hl.dsp.window.move({ direction = "l" }))
hl.bind(mainMod .. " + SHIFT + down",  hl.dsp.window.move({ direction = "d" }))
hl.bind(mainMod .. " + SHIFT + up",    hl.dsp.window.move({ direction = "u" }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ direction = "r" }))

-- Fullscreen toggle
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))

hl.bind(mainMod .. " + space", hl.dsp.window.float({ action = "toggle" }))

-- Toggle
hl.bind(mainMod .. " + W", hl.dsp.group.toggle())
hl.bind(mainMod .. " + T", hl.dsp.layout("togglesplit"))


--------------------
---- WORKSPACES ----
--------------------

-- Next / prev workspace
hl.bind(alt .. " + CTRL + right", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(alt .. " + CTRL + left",  hl.dsp.focus({ workspace = "e-1" }))

-- Direct workspace selection, and move focused window to workspace
for i = 1, 6 do
    hl.bind(mainMod .. " + " .. i,           hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. i,   hl.dsp.window.move({ workspace = i }))
end


---------------------
---- RESIZE MODE ----
---------------------

hl.bind(mainMod .. " + R", hl.dsp.submap("resize"))

hl.define_submap("resize", function()
    hl.bind("down",  hl.dsp.window.resize({ x = 0,   y = 20,  relative = true }), { repeating = true })
    hl.bind("up",    hl.dsp.window.resize({ x = 0,   y = -20, relative = true }), { repeating = true })
    hl.bind("right", hl.dsp.window.resize({ x = 20,  y = 0,   relative = true }), { repeating = true })
    hl.bind("left",  hl.dsp.window.resize({ x = -20, y = 0,   relative = true }), { repeating = true })

    hl.bind("return", hl.dsp.submap("reset"))
    hl.bind("escape", hl.dsp.submap("reset"))
end)


----------------------
---- WINDOW RULES ----
----------------------

-- Ignore maximize requests from apps (kitty >= 0.49 requests it on startup)
hl.window_rule({
    match          = { class = ".*" },
    suppress_event = "maximize",
})

hl.window_rule({
    match = { class = "^(qalculate-gtk)$" },
    float = true,
    size  = { 700, 520 },
})

hl.window_rule({
    match = { class = "^(org\\.pulseaudio\\.pavucontrol)$" },
    float = true,
    size  = { 900, 600 },
})

hl.window_rule({
    match = { class = "clipse" },
    float = true,
    size  = { 622, 652 },
})

-- Float Thunar dialogs (rename, bulk rename, etc.) instead of tiling them
hl.window_rule({
    match  = { class = "^(Thunar)$", title = "^(Rename).*$" },
    float  = true,
    size   = { 480, 180 },
    center = true,
})

hl.window_rule({
    match            = { class = "^(jetbrains-.*)$", title = "^win.*$" },
    no_initial_focus = true,
    rounding         = 0,
})

hl.window_rule({
    match            = { class = "^(jetbrains-.*)$", title = "^$", float = true },
    no_initial_focus = true,
})

hl.window_rule({
    match        = { class = "^(jetbrains-.*)$", title = "^win.*$", float = true },
    stay_focused = true,
})

hl.window_rule({
    match        = { class = "^(jetbrains-toolbox)$" },
    float        = true,
    move         = { "cursor_x-(window_w*0.5)", "cursor_y-(window_h*0.5)" },
    stay_focused = true,
})
