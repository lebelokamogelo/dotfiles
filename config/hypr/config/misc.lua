hl.config({
    general = {
        layout = "master",
        snap = {
            enabled = true,
            respect_gaps = true,
        },
    },
    master = {
        mfact = 0.5,
        new_on_top = true,
        new_status = "slave",
        allow_small_split = true,
    },
    dwindle = {
        preserve_split = true,
    },
    misc = {
        col = {
            splash = CACHYLGREEN,
        },
        disable_hyprland_logo = true,
        disable_splash_rendering = true,
        force_default_wallpaper = 0,
        allow_session_lock_restore = true,
        anr_missed_pings = 5,
        middle_click_paste = false,
        -- let dialogs that request focus have it
        focus_on_activate = true,
        mouse_move_enables_dpms = true,
        key_press_enables_dpms = true,
        enable_swallow = true,
        swallow_regex = "(kitty|ghostty|[Kk]onsole|Alacritty|gnome-terminal|xfce[0-9]?-terminal)",
        vrr = 3,
    },
    xwayland = {
        force_zero_scaling = true
    },
    ecosystem = {
        no_update_news = true,
        no_donation_nag = true,
    },
})
