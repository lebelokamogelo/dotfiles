local mainMod = "SUPER"
local launchPrefix = "uwsm app -- " -- if you are not using UWSM, make this empty (e.g. "")

local LAUNCHER    = "rofi -show drun"
local WINDOW_SW   = "rofi -show window"
local CLIPBOARD   = [[cliphist list | rofi -dmenu -p "Clipboard" | cliphist decode | wl-copy]]
local NOTIF_PANEL = "swaync-client -t -sw"
local LOCK        = "hyprlock"
local SESSION     = "wlogout -b 5"

local VOL_UP   = "wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+"
local VOL_DOWN = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
local VOL_MUTE = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
local MIC_MUTE = "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"

---------------------------
---- WINDOW MANAGEMENT ----
---------------------------

-- Window manipulation
hl.bind(mainMod .. " + Escape",      hl.dsp.exec_cmd("hyprctl kill"))
hl.bind(mainMod .. " + Q",           hl.dsp.window.close())
hl.bind(mainMod .. " + ALT + Space", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + D",           hl.dsp.window.fullscreen({ mode = 1 }))
hl.bind(mainMod .. " + F",           hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + J",           hl.dsp.layout("togglesplit"))

-- Change focus
hl.bind(mainMod .. " + Left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + Right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + Up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + Down",  hl.dsp.focus({ direction = "down" }))
hl.bind("ALT + Tab",           hl.dsp.window.cycle_next())
hl.bind(mainMod .. " + Tab",   hl.dsp.exec_cmd(WINDOW_SW))

-- Move active window around workspaces & monitors
hl.bind(mainMod .. " + SHIFT + Up",                   hl.dsp.window.move({ direction = "u" }))
hl.bind(mainMod .. " + SHIFT + Right",                hl.dsp.window.move({ direction = "r" }))
hl.bind(mainMod .. " + SHIFT + Left",                 hl.dsp.window.move({ direction = "l" }))
hl.bind(mainMod .. " + SHIFT + Down",                 hl.dsp.window.move({ direction = "d" }))
hl.bind(mainMod .. " + SHIFT + mouse_up",             hl.dsp.window.move({ monitor   = "-1" }))
hl.bind(mainMod .. " + SHIFT + mouse_down",           hl.dsp.window.move({ monitor   = "+1" }))
hl.bind(mainMod .. " + CONTROL + SHIFT + Right",      hl.dsp.window.move({ workspace = "m+1" }))
hl.bind(mainMod .. " + CONTROL + SHIFT + Left",       hl.dsp.window.move({ workspace = "m-1" }))
hl.bind(mainMod .. " + CONTROL + SHIFT + mouse_up",   hl.dsp.window.move({ workspace = "m-1" }))
hl.bind(mainMod .. " + CONTROL + SHIFT + mouse_down", hl.dsp.window.move({ workspace = "m+1" }))
for i = 1, NUM_WPM do
    local key = i % 10
    hl.bind(mainMod .. " + SHIFT + CONTROL + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Move & Resize with mouse
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag())
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize())

-- Zoom
local function zoomfunction(value)
    local zoomvalue = hl.get_config("cursor:zoom_factor")
    if (zoomvalue + value) > 3.0 then
        hl.config({ cursor = { zoom_factor = 3.0 } })
    elseif (zoomvalue + value) < 1.0 then
        hl.config({ cursor = { zoom_factor = 1.0 } })
    else
        hl.config({ cursor = { zoom_factor = zoomvalue + value } })
    end
end
hl.bind(mainMod .. " + Minus", function() zoomfunction(-0.3) end, { repeating = true})
-- On the `us` layout the "Plus" keysym only exists as SHIFT+equal, so SUPER+Plus is
-- really SUPER+SHIFT+plus and cannot match a SUPER-only modmask. Bind the unshifted
-- Equal as well so zoom-in is reachable without contorting.
hl.bind(mainMod .. " + Equal", function() zoomfunction(0.3) end, { repeating = true })
hl.bind(mainMod .. " + SHIFT + Plus", function() zoomfunction(0.3) end, { repeating = true })

--# Zoom with keypad
-- The Lua bind parser does not understand the `code:NN` form used by hyprland.conf --
-- it registers the bind with no key at all (key="" keycode=0), i.e. dead. Use keysyms.
hl.bind(mainMod .. " + KP_Subtract", function() zoomfunction(-0.3) end, { repeating = true })
hl.bind(mainMod .. " + KP_Add", function() zoomfunction(0.3) end, { repeating = true })


------------------
---- LAUNCHER ----
------------------

hl.bind(mainMod .. " + Return",     hl.dsp.exec_cmd(launchPrefix .. TERMINAL))
hl.bind(mainMod .. " + E",          hl.dsp.exec_cmd(launchPrefix .. FILE_MANAGER))
hl.bind(mainMod .. " + SHIFT + E",  hl.dsp.exec_cmd(launchPrefix .. TERMINAL .. " -e yazi"))
hl.bind(mainMod .. " + T",          hl.dsp.exec_cmd(launchPrefix .. EDITOR))
hl.bind(mainMod .. " + C",          hl.dsp.exec_cmd(launchPrefix .. CALCULATOR))
hl.bind("XF86Calculator",           hl.dsp.exec_cmd(launchPrefix .. CALCULATOR))
hl.bind(mainMod .. " + W",          hl.dsp.exec_cmd(launchPrefix .. BROWSER))
hl.bind("CONTROL + SHIFT + Escape", hl.dsp.exec_cmd(launchPrefix .. TERMINAL .. " -e btop"))
hl.bind(mainMod .. " + Space",      hl.dsp.exec_cmd(LAUNCHER))
hl.bind(mainMod .. " + X",          hl.dsp.exec_cmd(NOTIF_PANEL))
hl.bind(mainMod .. " + L",          hl.dsp.exec_cmd(LOCK))
hl.bind(mainMod .. " + ALT + C",    hl.dsp.exec_cmd(SESSION))
hl.bind(mainMod .. " + Z",          hl.dsp.exec_cmd("killall -SIGUSR1 waybar"))

---------------------------
---- HARDWARE CONTROLS ----
---------------------------

-- Audio
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd(VOL_UP),   { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd(VOL_DOWN), { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd(VOL_MUTE), { locked = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd(MIC_MUTE), { locked = true })

-- Media
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })

-- Brightness
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl set 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 5%-"), { locked = true, repeating = true })

-------------------
---- UTILITIES ----
-------------------

-- Screen Capture
-- Without --output-filename satty disables saving entirely, which is why the
-- save buttons were missing from the preview toolbar.
local SATTY = table.concat({
    "satty -f -",
    "--output-filename ~/Pictures/Screenshots/screenshot-%Y%m%d-%H%M%S.png",
    "--copy-command wl-copy",
    "--auto-copy",                                          -- keep clipboard in sync while annotating
    "--actions-on-enter save-to-clipboard,save-to-file,exit",
    -- Scoped to the save triggers on purpose: a bare --early-exit also fires on
    -- copy, which --auto-copy triggers on every annotation, closing the window.
    "--early-exit save,save-as",
    "--resize smart",
}, " ")

-- tee into wl-copy so the raw shot is on the clipboard the instant it is taken,
-- before satty even draws; --auto-copy then keeps it current as you annotate.
local CLIP = "tee >(wl-copy) | "

local SHOT_REGION = [[grim -g "$(slurp)" - | ]] .. CLIP .. SATTY
local SHOT_FULL   = "grim - | " .. CLIP .. SATTY

hl.bind(mainMod .. " + P",         hl.dsp.exec_cmd("hyprpicker -a -n"))
hl.bind("Print",                   hl.dsp.exec_cmd(SHOT_REGION))
hl.bind(mainMod .. " + Print",     hl.dsp.exec_cmd(SHOT_FULL))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd(SHOT_REGION))

-- Clipboard
hl.bind(mainMod .. " + V", hl.dsp.exec_cmd(CLIPBOARD))

-- Notifications
hl.bind(mainMod .. " + A", hl.dsp.exec_cmd(NOTIF_PANEL))

-------------------------------
---- WORKSPACES & MONITORS ----
-------------------------------

for i = 1, NUM_WPM do
    local key = i % 10
    -- Absolute IDs, not "m~i": the m~ selector only walks workspaces that already
    -- exist, so with non-persistent workspaces it silently no-ops on empty ones.
    hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
    hl.bind(mainMod .. " + ALT + " .. key,   hl.dsp.focus({ workspace = i }))
end

for i = 1, NUM_WPM do
    local key = i % 10
    hl.bind(mainMod .. " + CONTROL + " .. key, hl.dsp.focus({ workspace = i }))
end

for i, mon in ipairs({ MONITOR1, MONITOR2, MONITOR3 }) do
    if mon ~= "" then
        hl.bind(mainMod .. " + ALT + SHIFT + " .. i,   hl.dsp.focus({ monitor = mon }))
        hl.bind(mainMod .. " + CONTROL + ALT + " .. i, hl.dsp.window.move({ monitor = mon }))
    end
end

-- Move to adjacent workspaces and next empty on a given monitor
hl.bind(mainMod .. " + CONTROL + Right",       hl.dsp.focus({ workspace = "m+1" }))
hl.bind(mainMod .. " + CONTROL + Left",        hl.dsp.focus({ workspace = "m-1" }))
hl.bind(mainMod .. " + CONTROL + Down",        hl.dsp.focus({ workspace = "emptym" }))

-- Scroll through existing workspaces & monitors.
-- These were inverted relative to every other scroll pair in this file: SUPER+scroll
-- sent up->m+1 while SUPER+CONTROL+scroll (the same action) sent up->m-1, and both
-- SHIFT variants above use up->-1. Aligned on the majority: up = previous, down = next.
hl.bind(mainMod .. " + mouse_up",             hl.dsp.focus({ workspace = "m-1" }))
hl.bind(mainMod .. " + mouse_down",           hl.dsp.focus({ workspace = "m+1" }))
hl.bind(mainMod .. " + CONTROL + mouse_up",   hl.dsp.focus({ workspace = "m-1" }))
hl.bind(mainMod .. " + CONTROL + mouse_down", hl.dsp.focus({ workspace = "m+1" }))

-- Special workspace (scratchpad)
-- Moved off SUPER+SHIFT+S: that shortcut reads as "screenshot" from muscle memory,
-- and movetoworkspace-special also *opens* the scratchpad, which then stays layered
-- over every workspace you switch to -- looking exactly like workspace switching broke.
hl.bind(mainMod .. " + ALT + S", hl.dsp.window.move({ workspace = "special" }))
hl.bind(mainMod .. " + S",       hl.dsp.workspace.toggle_special())
