# dotfiles

My Hyprland desktop on CachyOS. Clone, run `install.sh`, get the same setup back.

```bash
git clone https://github.com/lebelokamogelo/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

Then log out and back into Hyprland.

`install.sh` backs up anything it would overwrite to `~/.config-backup-<timestamp>/`,
so it is safe to run on a machine that already has configs. Use `--dry-run` to
preview, `--no-pkgs` to deploy configs without touching pacman.

## What's in here

| Path | Goes to | What it is |
|---|---|---|
| `config/hypr/` | `~/.config/hypr/` | Hyprland (Lua config), hyprlock, hypridle, hyprpaper |
| `config/waybar/` | `~/.config/waybar/` | Bar layout, styling, helper scripts |
| `config/rofi/` | `~/.config/rofi/` | Launcher theme |
| `config/swaync/` | `~/.config/swaync/` | Notification centre |
| `config/kitty/` | `~/.config/kitty/` | Terminal |
| `config/fish/` | `~/.config/fish/` | Shell (excludes `fish_variables` — machine state) |
| `config/wlogout/` | `~/.config/wlogout/` | Logout menu |
| `config/btop/`, `gtk-*`, `qt6ct/`, `nwg-look/` | `~/.config/` | Theming + monitoring |
| `systemd/user/` | `~/.config/systemd/user/` | Restart drop-ins for waybar + hyprpaper |
| `local/bin/setbg` | `~/.local/bin/setbg` | Wallpaper switcher |
| `sddm/navy/` | `/usr/share/sddm/themes/` | Login screen theme (needs root) |
| `packages.txt` | — | Package list installed by `install.sh` |

## Notes

**waybar and hyprpaper run under systemd, not Hyprland's autostart.** Waybar's
mpris module can segfault, and launched fire-and-forget nothing restarted it.
The drop-ins in `systemd/user/` set `Restart=always`.

**The wallpaper lives in two configs** — `hyprpaper.conf` (desktop) and
`hyprlock.conf` (lock screen). `setbg` writes both.

**SDDM theme** in `sddm/navy/`, installed to `/usr/share/sddm/themes/` with a
`/etc/sddm.conf.d/10-theme.conf` drop-in. Colours, background, blur and fonts
are all in `theme.conf`. Preview it without installing:

```bash
sddm-greeter-qt6 --test-mode --theme ./sddm/navy
```

## setbg

```bash
setbg                    # rofi picker with thumbnails
setbg path/to/image.png  # set directly
setbg -r                 # random
setbg -l                 # list everything found
setbg -c                 # show current
setbg --no-lock <img>    # desktop only, leave lock screen alone
```

Applies live over hyprpaper IPC (no restart), then persists to both configs.
Searches `~/.local/share/wallpapers`, `~/Pictures/wallpapers`, and
`/usr/share/wallpapers`. Edit `WALLPAPER_DIRS` at the top to add more.

hyprpaper ≥0.8 dropped the `preload` IPC command; `wallpaper` loads on demand.

## Hardware assumptions

Built for a single 1920x1080 laptop panel on `eDP-1`. On different hardware,
adjust `config/hypr/config/monitors.lua` and the `output` in
`config/waybar/config.jsonc`.
