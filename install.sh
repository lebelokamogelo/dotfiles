#!/usr/bin/env bash
# Restore this Hyprland setup on a fresh CachyOS / Arch machine.
# Existing configs are backed up to ~/.config-backup-<timestamp>/ first.

set -uo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP="$HOME/.config-backup-$STAMP"

INSTALL_PKGS=1
DRY_RUN=0

c_ok()   { printf '\033[32m✓\033[0m %s\n' "$*"; }
c_info() { printf '\033[36m→\033[0m %s\n' "$*"; }
c_warn() { printf '\033[33m!\033[0m %s\n' "$*"; }
c_err()  { printf '\033[31m✗\033[0m %s\n' "$*" >&2; }
die()    { c_err "$*"; exit 1; }

run() {
    if [[ $DRY_RUN -eq 1 ]]; then
        printf '   \033[90mwould run:\033[0m %s\n' "$*"
    else
        "$@"
    fi
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --no-pkgs) INSTALL_PKGS=0; shift ;;
        --dry-run) DRY_RUN=1; shift ;;
        -h|--help)
            cat <<'EOF'
./install.sh            install packages, then deploy configs
./install.sh --no-pkgs  deploy configs only, skip pacman
./install.sh --dry-run  show what would happen, change nothing
EOF
            exit 0 ;;
        *)         die "unknown option: $1" ;;
    esac
done

[[ $EUID -eq 0 ]] && die "do not run this as root — it installs into \$HOME"
command -v pacman >/dev/null || die "pacman not found; this expects Arch/CachyOS"
[[ $DRY_RUN -eq 1 ]] && c_warn "dry run — nothing will be changed"

# ---------------------------------------------------------------- packages ---
if [[ $INSTALL_PKGS -eq 1 ]]; then
    c_info "installing packages from packages.txt"
    mapfile -t PKGS < <(grep -vE '^\s*(#|$)' "$REPO/packages.txt")

    missing=()
    for p in "${PKGS[@]}"; do
        pacman -Q "$p" &>/dev/null || missing+=("$p")
    done

    if [[ ${#missing[@]} -eq 0 ]]; then
        c_ok "all ${#PKGS[@]} packages already installed"
    else
        c_info "${#missing[@]} missing: ${missing[*]}"
        run sudo pacman -S --needed --noconfirm "${missing[@]}" \
            || c_warn "some packages failed — continuing with config deploy"
    fi
else
    c_info "skipping package install (--no-pkgs)"
fi

# ----------------------------------------------------------------- configs ---
deploy() {   # deploy <source> <destination>
    local src="$1" dst="$2"
    [[ -e $src ]] || return 0

    if [[ -e $dst ]]; then
        run mkdir -p "$BACKUP/$(dirname "${dst#$HOME/}")"
        run mv "$dst" "$BACKUP/${dst#$HOME/}"
        c_warn "backed up existing $(basename "$dst")"
    fi
    run mkdir -p "$(dirname "$dst")"
    run cp -r "$src" "$dst"
    c_ok "$(basename "$dst")"
}

c_info "deploying configs to ~/.config"
for src in "$REPO"/config/*; do
    deploy "$src" "$HOME/.config/$(basename "$src")"
done

c_info "deploying systemd user units"
for src in "$REPO"/systemd/user/*; do
    deploy "$src" "$HOME/.config/systemd/user/$(basename "$src")"
done

c_info "deploying scripts to ~/.local/bin"
run mkdir -p "$HOME/.local/bin"
for src in "$REPO"/local/bin/*; do
    run cp "$src" "$HOME/.local/bin/$(basename "$src")"
    run chmod +x "$HOME/.local/bin/$(basename "$src")"
    c_ok "$(basename "$src")"
done

if [[ ! -d $HOME/.local/share/icons/Bibata-Modern-Ice ]]; then
    c_info "installing Bibata-Modern-Ice cursor"
    if [[ $DRY_RUN -eq 1 ]]; then
        printf '   \033[90mwould download:\033[0m Bibata-Modern-Ice.tar.xz\n'
    elif mkdir -p "$HOME/.local/share/icons" &&
         curl -fsSL https://github.com/ful1e5/Bibata_Cursor/releases/latest/download/Bibata-Modern-Ice.tar.xz |
         tar -xJ -C "$HOME/.local/share/icons"; then
        c_ok "Bibata-Modern-Ice"
    else
        c_warn "cursor download failed — falling back to the default cursor"
    fi
fi

c_info "deploying launcher entries to ~/.local/share/applications"
run mkdir -p "$HOME/.local/share/applications"
run cp "$REPO"/local/share/applications/*.desktop "$HOME/.local/share/applications/"
c_ok "launcher entries"

if command -v gsettings >/dev/null; then
    run gsettings set org.gnome.desktop.interface gtk-theme adw-gtk3-dark
    run gsettings set org.gnome.desktop.interface icon-theme Papirus-Dark
    run gsettings set org.gnome.desktop.interface color-scheme prefer-dark
    run gsettings set org.gnome.desktop.interface cursor-theme Bibata-Modern-Ice
    c_ok "gtk theme, icons and cursor"
fi

# waybar's own helper scripts must stay executable
[[ -d $HOME/.config/waybar/scripts ]] && run chmod +x "$HOME"/.config/waybar/scripts/*.sh 2>/dev/null

# ------------------------------------------------------------------ sddm ---
# Needs root, so it is last: everything above still lands if sudo is declined.
if [[ -d "$REPO/sddm" ]]; then
    c_info "installing SDDM theme (needs sudo)"
    if run sudo cp -r "$REPO"/sddm/. /usr/share/sddm/themes/; then
        run sudo mkdir -p /etc/sddm.conf.d
        # A drop-in, so an existing /etc/sddm.conf (autologin etc) is preserved.
        if [[ $DRY_RUN -eq 0 ]]; then
            printf '[Theme]\nCurrent=navy\n' |
                sudo tee /etc/sddm.conf.d/10-theme.conf >/dev/null
        fi
        bg=$(awk -F= '/^[[:space:]]*path[[:space:]]*=/ { gsub(/^[ \t]+|[ \t]+$/, "", $2); print $2; exit }' \
                 "$HOME/.config/hypr/hyprlock.conf" 2>/dev/null)
        [[ -f $bg ]] || bg=/usr/share/wallpapers/cachyos-wallpapers/Abstract.png
        if [[ -f $bg ]]; then
            run sudo install -o "$USER" -m 644 "$bg" /usr/share/sddm/themes/navy/background
        else
            c_warn "no wallpaper found for the login screen"
        fi
        c_ok "sddm theme 'navy'"
        for f in /etc/sddm.conf /etc/sddm.conf.d/*.conf; do
            [[ -f $f && $f != */10-theme.conf ]] || continue
            grep -q '^Current=' "$f" && c_warn "$f also sets the SDDM theme and may override navy"
        done
    else
        c_warn "sddm theme skipped"
    fi
fi

# ---------------------------------------------------------------- services ---
c_info "enabling system services (needs sudo)"
for svc in sddm bluetooth; do
    if run sudo systemctl enable "$svc.service" &>/dev/null; then
        c_ok "$svc.service enabled"
    else
        c_warn "could not enable $svc.service"
    fi
done

c_info "enabling user services"
if [[ $DRY_RUN -eq 0 ]] && systemctl --user show-environment &>/dev/null; then
    systemctl --user daemon-reload
    for svc in waybar hyprpaper swaync hypridle hyprpolkitagent; do
        if systemctl --user enable "$svc.service" &>/dev/null; then
            c_ok "$svc.service enabled"
        else
            c_warn "could not enable $svc.service"
        fi
    done
else
    run systemctl --user daemon-reload
    run systemctl --user enable waybar.service hyprpaper.service swaync.service hypridle.service hyprpolkitagent.service
fi

# Waybar draws network and bluetooth natively, so the tray applets are redundant.
# Hidden=true in config/autostart is not enough — systemd's xdg-autostart
# generator starts them anyway, so the generated units need masking.
c_info "masking redundant tray applets"
for unit in 'app-blueman@autostart.service' 'app-nm\x2dapplet@autostart.service'; do
    if run systemctl --user mask "$unit" &>/dev/null; then
        c_ok "$unit masked"
    else
        c_warn "could not mask $unit"
    fi
done

# ------------------------------------------------------------------- notes ---
echo
c_ok "done"
[[ -d $BACKUP ]] && c_info "previous configs saved to $BACKUP"
cat <<'EOF'

Next steps:
  1. Log out and back into Hyprland (or reboot) so the session picks it up.
  2. Set a wallpaper:            setbg
  3. Check the bar is running:   systemctl --user status waybar

Notes:
  - Monitors are configured in ~/.config/hypr/config/monitors.lua — the layout
    there is for a single 1920x1080 eDP-1 laptop panel. Adjust for new hardware.
  - Wallpapers come from the cachyos-wallpapers package (/usr/share/wallpapers).
    On non-CachyOS Arch, install your own and point setbg at them.
EOF
