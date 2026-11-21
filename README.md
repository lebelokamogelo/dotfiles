# dotfiles

My Hyprland desktop on CachyOS. Clone, run `install.sh`, get the same setup back.

```bash
git clone https://github.com/lebelokamogelo/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

On a fresh machine, install CachyOS with **no desktop**, log in on the TTY, then
clone and run `install.sh` as above. It installs everything in `packages.txt`
(SDDM included), enables `sddm` and `bluetooth`, and downloads the Bibata
cursor. Reboot and pick nothing — SDDM defaults to "Hyprland (uwsm-managed)".

On an existing install, log out and back into Hyprland.

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
| `config/starship/` | `~/.config/starship/` | Plain prompt (no icons or version badges) |
| `config/fish/` | `~/.config/fish/` | Shell (excludes `fish_variables` — machine state) |
| `config/wlogout/` | `~/.config/wlogout/` | Logout menu |
| `config/btop/`, `gtk-*`, `qt6ct/`, `nwg-look/` | `~/.config/` | Theming + monitoring |
| `config/uwsm/` | `~/.config/uwsm/` | Session environment (Qt, cursor, Wayland hints) |
| `systemd/user/` | `~/.config/systemd/user/` | Restart drop-ins for waybar + hyprpaper |
| `local/bin/setbg` | `~/.local/bin/setbg` | Wallpaper switcher |
| `local/bin/project` | `~/.local/bin/project` | Second screen / projector menu |
| `sddm/navy/` | `/usr/share/sddm/themes/` | Login screen theme (needs root) |
| `packages.txt` | — | Package list installed by `install.sh` |

## Notes

**Daemons run under systemd, not Hyprland's autostart.** waybar, hyprpaper,
swaync, hypridle and hyprpolkitagent are user services, so they restart on
crash. Waybar's mpris module can segfault; the drop-ins in `systemd/user/` set
`Restart=always` for waybar and hyprpaper.

**Login is the uwsm session.** Environment variables go in `config/uwsm/env`,
not in Hyprland's config, so systemd services see them too. Nothing should set
`HYPRLAND_CONFIG` there — Hyprland must load `~/.config/hypr/hyprland.lua`.

**The wallpaper lives in three places** — `hyprpaper.conf` (desktop),
`hyprlock.conf` (lock screen) and `/usr/share/sddm/themes/navy/background`
(login screen). `setbg` writes all three. SDDM cannot read `~`, so the login
image is a copy; `install.sh` creates it owned by you so `setbg` needs no sudo.

**SDDM theme** in `sddm/navy/`, installed to `/usr/share/sddm/themes/` with a
`/etc/sddm.conf.d/10-theme.conf` drop-in. Drop-ins are read alphabetically and
the last `Current=` wins, so any other file there that sets a theme overrides
navy; `install.sh` warns if it finds one. Colours, background, blur and fonts
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
setbg --no-lock <img>    # desktop only, leave lock and login screens alone
```

Applies live over hyprpaper IPC (no restart), then persists to both configs.
Searches `~/.local/share/wallpapers`, `~/Pictures/wallpapers`, and
`/usr/share/wallpapers`. Edit `WALLPAPER_DIRS` at the top to add more.

hyprpaper ≥0.8 dropped the `preload` IPC command; `wallpaper` loads on demand.

## Second screens and projectors

Workspaces are not pinned to monitors. A screen that gets plugged in opens on
the next free workspace (laptop on 1–2 → new screen gets 3), and gives its
workspaces back when unplugged.

`SUPER+P` opens a Windows-style project menu (`local/bin/project`):

| Choice | Effect |
|---|---|
| Extend | Separate desktop on the second screen (the default) |
| Duplicate | Mirror the laptop screen |
| PC screen only | Turn the second screen off |

Also scriptable: `project extend|duplicate|pc`. The colour picker moved to
`SUPER+SHIFT+P`.

## Hardware assumptions

Built for a 1920x1080 laptop panel on `eDP-1`. External screens use their best
advertised mode (`highres`), so projectors never get a mode they cannot show.
On different hardware, adjust `config/hypr/config/monitors.lua`.
