-- Window rules wiki https://wiki.hypr.land/Configuring/Basics/Window-Rules/

-- Generic floating position
hl.window_rule({ match = { float = true }, center = true, persistent_size = true })

-- Picture-in-Picture
hl.window_rule({
    match             = { title = "^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$" },
    float             = true,
    keep_aspect_ratio = true,
    size              = { "max(monitor_w, monitor_h)*0.25", "min(monitor_w, monitor_h)*0.25" },
    pin               = true,
})

-- Gaming
local gamingApps = "^(steam_app.*|gamescope)$"
local gamingWorkspace = "name:gaming"

hl.window_rule({ match = { content = "game" }, workspace = gamingWorkspace })
hl.window_rule({ match = { xdg_tag = "^(.*game.*)$" }, workspace = gamingWorkspace, fullscreen_state = 2, content = "game", sync_fullscreen = true })
hl.window_rule({ match = { class = gamingApps }, workspace = gamingWorkspace })
hl.window_rule({ match = { class = "^(steam)$", title = "^(Friends List)$" }, float = true })
hl.window_rule({ match = { class = "^(steam)$", title = "^(Launching\\.{3})$" }, float = true, center = true, workspace = gamingWorkspace })
hl.window_rule({
    match = {
        class         = gamingApps,
        title         = "^(.+)$",
        initial_title = "negative:^(.*\\\\home\\\\.*)$",
    },
    content          = "game",
    decorate         = false,
    fullscreen_state = 2,
    size             = { "monitor_w", "monitor_h" },
    sync_fullscreen  = true,
})
hl.window_rule({
    match = {
        class         = "^(steam_app.*)$",
        initial_title = "^$",
    },
    center           = true,
    float            = true,
    fullscreen       = false,
    fullscreen_state = 0,
    workspace        = gamingWorkspace,
})

-- Apps
hl.window_rule({ match = { class = "^(.*\\.exe)$", float = true }, monitor = PRIMARY_MONITOR, center = true, fullscreen_state = 0 })
hl.window_rule({ match = { class = "^(.*[Ll]auncher.*)$" }, float = true, monitor = PRIMARY_MONITOR })
hl.window_rule({ match = { class = "^(vesktop|discord)$" }, monitor = PRIMARY_MONITOR })
hl.window_rule({ match = { class = "^(.*[Cc]alc.*)$" }, float = true, size = { "max(monitor_w, monitor_h)*0.17", "min(monitor_w, monitor_h)*0.43" } })
hl.window_rule({ match = { class = "^(org\\.kde\\.keditfiletype)$" }, float = true })
hl.window_rule({ match = { class = "^(org\\.kde\\.ark)$" }, size = { "max(monitor_w, monitor_h)*0.40", "min(monitor_w, monitor_h)*0.40" } })
-- Screenshot annotator. Satty reports class/title as lowercase "satty", so match
-- on class alone -- a "^(Satty)$" title condition never fires and the window tiles.
hl.window_rule({
    match    = { class = "^(com\\.gabm\\.satty|.*[Ss]atty.*)$" },
    float    = true,
    center   = true,
    size     = { "monitor_w*0.75", "monitor_h*0.75" },
    min_size = { "max(monitor_w, monitor_h)*0.45", "min(monitor_w, monitor_h)*0.45" },
})
hl.window_rule({
    match = {
        class = "^(org\\.gnome\\.Nautilus)$",
        title = "negative:^(Moving.*|Create New.*|Extract.*|Compress.*|Copying.*|Progress.*|Preferences.*|Properties.*|Open With.*)$",
    },
    float = true,
    size = { "max(monitor_w, monitor_h)*0.50", "min(monitor_w, monitor_h)*0.55" },
    center = true,
})

-- Opacity Overrides
local terminals = "^(kitty|ghostty|[Kk]onsole|Alacritty|gnome-terminal|xfce[0-9]?-terminal)$"

hl.window_rule({ match = { class = "^(firefox|zen|brave-browser|Brave-browser)$" }, opacity = "1.0 override" })
hl.window_rule({ match = { class = terminals }, opacity = "1.0 override" }) -- Override opacity in favor of terminal settings for opacity. If your terminal doesn't support transparency, you can remove this rule.
hl.window_rule({ match = { class = "^(mpv|org.kde.haruna|.*plex.*|org\\.kde\\.gwenview|.*vlc.*)$" }, opacity = "1.0 override" })

-- Float Utility Windows
local floatApps = {
    { class = "^(kvantummanager|qt[56]ct|nwg-look)$" },
    { class = "^(org.pulseaudio.pavucontrol|blueman-manager|nm-applet|nm-connection-editor)$" },
    { title = "^(Winetricks.*|Protontricks.*)$" },
}
for _, m in ipairs(floatApps) do hl.window_rule({ match = m, float = true }) end

-- Chromium/Brave extension popups (Bitwarden, uBlock, any toolbar dropdown) are not
-- real popups: each opens as its own toplevel window with class
-- brave-<extension-id>-Default and title _crx_<extension-id>. The id is always 32
-- chars from a-p. Nothing else in this file matches that shape, so they were landing
-- in the tiling layout and shoving the browser aside instead of appearing as a
-- dropdown. Floating them restores the popup behaviour and lets them keep the size
-- the extension asked for. Capped like the modals below so a misbehaving one cannot
-- exceed the usable area.
-- Browser extension popups (Bitwarden etc). Chromium destroys them on focus loss,
-- so pin focus. Class is brave-<32-char extension id>-Default.
hl.window_rule({
    match        = { class = "^(brave|brave-browser|chromium|google-chrome)-[a-p]{32}-Default$" },
    float        = true,
    center       = true,
    stay_focused = true,
    max_size     = { "monitor_w*0.85", "monitor_h*0.85" },
})

-- Float Common Modals
local modalMatches = {
    { title = "^(Open|Authentication Required|Add Folder to Workspace|Choose Files|Save As|Confirm to replace files|File Operation Progress)$" },
    { initial_title = "^(Open File)$" },
    { class = "^([Xx]dg-desktop-portal-gtk)$" },
    { title = "^(File Upload|Choose wallpaper|Library)(.*)$" },
    { class = "^(.*dialog.*)$" },
    -- initial_title, not title: matching the live title floats any window that merely
    -- *becomes* "...dialog..." later -- an editor opening dialog.ts, or a browser tab
    -- whose page title contains the word -- yanking a tiled window out of the layout.
    { initial_title = "^(.*dialog.*)$" },
    { class = "^(hyprland-share-picker)$"},
}

-- Modals float, and are also size-capped. GTK file choosers restore their last
-- geometry from the dconf key org.gtk.Settings.FileChooser window-size and re-save it
-- on every close, so once it grows past the display it can never shrink back on its
-- own. This panel is 1920x1080 at scale 1.25 => only 1536x864 logical, 816 usable
-- under waybar, and a saved height of 903 exceeds that. The catch-all `center` rule at
-- the top of this file then centers the overflow evenly, parking the Cancel/Save
-- header ~20px above y=0 where it is unreachable. The cap makes that impossible for
-- every modal, not just the portal. monitor_w/monitor_h are logical px (verified).
for _, m in ipairs(modalMatches) do
    hl.window_rule({ match = m, float = true, max_size = { "monitor_w*0.85", "monitor_h*0.85" } })
end

-- Ignore maximize requests from all apps. You'll probably like this.
hl.window_rule({
    name  = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})

-- Fix some dragging issues with XWayland
hl.window_rule({
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },
    no_focus = true,
})

-------------------
---- LAYER RULES --
-------------------
local blurredLayers = {
    "^(waybar)$",
    "^(rofi)$",
    "^(swaync-control-center)$",
    "^(swaync-notification-window)$",
}

for _, ns in ipairs(blurredLayers) do
    hl.layer_rule({ match = { namespace = ns }, blur = true, ignore_alpha = 0.3 })
end

hl.layer_rule({ match = { namespace = "^(logout_dialog)$" }, blur = true })
