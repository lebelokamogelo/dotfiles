#!/usr/bin/env bash
# install.sh — restore this Hyprland setup onto a fresh CachyOS / Arch machine.
#
#   ./install.sh              install packages, then deploy configs
#   ./install.sh --no-pkgs    deploy configs only, skip pacman
#   ./install.sh --dry-run    show what would happen, change nothing
#
# Any config it would overwrite is moved to ~/.config-backup-<timestamp>/ first,
# so this is safe to run on a machine that already has configs.

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
        -h|--help) sed -n '2,10p' "$0" | sed 's/^# \?//'; exit 0 ;;
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

# waybar's own helper scripts must stay executable
[[ -d $HOME/.config/waybar/scripts ]] && run chmod +x "$HOME"/.config/waybar/scripts/*.sh 2>/dev/null

# ---------------------------------------------------------------- services ---
# waybar and hyprpaper run under systemd (not hyprland's exec-once) so they
# restart automatically if they crash. The drop-ins deployed above add
# Restart=always; these two commands are what actually turn them on.
c_info "enabling user services"
if [[ $DRY_RUN -eq 0 ]] && systemctl --user show-environment &>/dev/null; then
    systemctl --user daemon-reload
    for svc in waybar hyprpaper; do
        if systemctl --user enable "$svc.service" &>/dev/null; then
            c_ok "$svc.service enabled"
        else
            c_warn "could not enable $svc.service"
        fi
    done
else
    run systemctl --user daemon-reload
    run systemctl --user enable waybar.service hyprpaper.service
fi

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
