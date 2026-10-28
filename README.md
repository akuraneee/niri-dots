# niri-dots

My dotfiles for [niri](https://github.com/YaLTeR/niri) on CachyOS / Arch.

| Package     | What's inside                                         |
|-------------|-------------------------------------------------------|
| `niri`      | compositor config: outputs, rules, binds              |
| `waybar`    | status bar                                            |
| `swaync`    | notifications                                         |
| `hypr`      | `hyprlock` (lock screen) and `hypridle` (auto-lock, monitors off) |
| `fuzzel`    | app launcher                                          |
| `ghostty`   | terminal                                              |
| `fish`      | shell                                                 |
| `fastfetch` | fastfetch with a custom logo                          |
| `waypaper`  | wallpaper picker on top of `awww`                     |

## Recreating the setup from scratch

Starting point: a fresh Arch / CachyOS install with a user, NetworkManager and an AUR helper (`yay`).

### 1. Packages

```bash
sudo pacman -S stow niri xwayland-satellite xdg-desktop-portal-gnome xdg-desktop-portal-gtk \
    waybar swaync awww hyprlock hypridle fuzzel ghostty fish starship lsd fastfetch \
    polkit-gnome gnome-keyring blueman copyq wl-clipboard \
    pavucontrol playerctl ddcutil brightnessctl power-profiles-daemon nautilus adw-gtk-theme \
    noto-fonts noto-fonts-cjk noto-fonts-emoji adwaita-fonts ttf-jetbrains-mono-nerd
```

```bash
yay -S waypaper normcap
```

For the YubiKey unlock (optional): `sudo pacman -S pam-u2f`.

Apps bound to hotkeys (install what you use): `helium-browser-bin`, `spotify`, `discord`, `keepassxc`,
and the flatpaks `md.obsidian.Obsidian` and `org.telegram.desktop`.

### 2. Fonts

- Waybar, fastfetch and the fuzzel menus use Nerd Font icons. I use **JetBrains Mono Nerd Font**
  (`ttf-jetbrains-mono-nerd` above); any other [Nerd Font](https://www.nerdfonts.com/) works too.
- UI font is the default `Adwaita Sans` / `Noto Sans`, emoji and CJK come from Noto.
- Ghostty uses its built-in font (JetBrains Mono) at size 10.

After installing fonts by hand into `~/.local/share/fonts`, run `fc-cache -f`.

### 3. Shell

```bash
chsh -s /usr/bin/fish
```

The prompt is [starship](https://starship.rs) with the default config, `ls` is `lsd`.

### 4. Dotfiles

Clone and link the packages (see [Installation](#installation) below for details):

```bash
git clone https://github.com/akuraneee/niri-dots ~/niri-dots
cd ~/niri-dots
stow */
```

Then:

- set your outputs in `niri/.config/niri/config.kdl` (names from `niri msg outputs`) and run `niri validate`;
- edit the `mbs*` aliases in `fish/.config/fish/config.fish` — they use my DDC bus numbers
  (`ddcutil detect` shows yours).

### 5. Dark mode

Apps are dark through the GNOME portal setting plus the `adw-gtk3-dark` theme for GTK3 apps:

```bash
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3-dark'
```

Qt apps follow it via `QT_QPA_PLATFORMTHEME=gnome`, which is already set in the niri config.

### 6. Wallpaper

Wallpapers are drawn by `awww` (started by niri) and picked with `waypaper` (`Mod+Shift+W`);
`awww` restores the last one on login. Mine is `13-Ventura-Dark.jpg` from a macOS wallpapers collection
unpacked into `~/Pictures/macOS-Wallpapers-main` — the folder waypaper opens. Put your own wallpapers
there or change `folder` in `waypaper/.config/waypaper/config.ini`.

Waypaper writes the current wallpaper back into that `config.ini`, so picking a new one shows up as a
change in the repo.

### 7. Log in

Log out, pick the **Niri** session in your display manager (I use GDM) and log in.
`Mod+/` shows all hotkeys. Laptop lid and YubiKey unlock need extra system setup, see [Notes](#notes).

## Installation

Every top-level folder is a separate stow package that mirrors `~`.
`.stowrc` already sets `--target=~` and `--no-folding` (files are linked, not whole folders,
so whatever apps write into `~/.config` on their own doesn't end up in the repo).

```bash
git clone https://github.com/akuraneee/niri-dots ~/niri-dots
cd ~/niri-dots
```

If you already have configs in `~/.config`, stow will refuse to overwrite them — move them to a backup first.
Preview what would be done without changing anything:

```bash
stow -n -v */
```

Link everything:

```bash
stow */
```

Or only what you need, for example:

```bash
stow niri waybar hypr
```

After adding new files to a package run `stow -R <package>`; to remove the links run `stow -D <package>`.

## Hotkeys

Press `Mod+/` in niri for the full list.

| Keys | Action |
|---|---|
| `Mod+Return` | terminal |
| `Mod+Z` | launcher (fuzzel) |
| `Mod+Q` | close window |
| `Mod+Tab` | overview |
| `Mod+H/J/K/L` | focus |
| `Mod+Shift+H/J/K/L` | move window / column |
| `Mod+Ctrl+H/L` | focus the other monitor |
| `Mod+1..9` / `Mod+Ctrl+1..9` | go to / move column to workspace |
| `Mod+D` / `Mod+F` | maximize column / fullscreen |
| `Mod+Space` | toggle floating |
| `Mod+X` | tabbed column |
| `Mod+V` | clipboard (copyq) |
| `Mod+N` / `Mod+U` | notifications / do not disturb |
| `Pause` / `Mod+M` | mute / unmute the microphone |
| `Mod+Shift+S` | screenshot a region |
| `Mod+Shift+T` | OCR (normcap) |
| `Mod+Shift+W` | pick a wallpaper (waypaper) |
| `Mod+I` / `Mod+Shift+I` | lock / suspend |
| `Mod+Ctrl+I` | caffeine: screen stays on, no auto-lock/suspend (cup icon in waybar) |

## Notes

- Outputs are set up for my monitors (`DP-1` + `HDMI-A-1`). Edit the "Outputs" section in `niri/.config/niri/config.kdl`; get your output names from `niri msg outputs`.
- After editing the niri config, run `niri validate`.
- To show an avatar on the lock screen, put an image at `~/.face`.
- Idle: unlocked — suspend after 15 min; locked — monitors off after 30 s, suspend after 5 min.
  Waking up always lands on the lock screen. Timings live in `hypr/.config/hypr/hypridle.conf`.
- Laptop lid: niri handles it (`scripts/lock-suspend.sh`), so logind must ignore it, otherwise it
  suspends before hyprlock is up and the desktop flashes on wake:

  ```sh
  sudo mkdir -p /etc/systemd/logind.conf.d
  printf '[Login]\nHandleLidSwitch=ignore\nHandleLidSwitchExternalPower=ignore\n' \
      | sudo tee /etc/systemd/logind.conf.d/lid.conf
  sudo systemctl kill -s HUP systemd-logind
  ```
- YubiKey unlock: `hypr/.config/hypr/scripts/lock.sh` runs hyprlock and, while it is up, waits for a
  key (also one plugged in after locking or reset by suspend) and unlocks on touch. hyprlock itself
  asks only for the password. Both need PAM services (register the key with `pamu2fcfg` first,
  into `~/.config/Yubico/u2f_keys`):

  ```sh
  sudo tee /etc/pam.d/hyprlock-password <<'PAM'
  auth      required                    pam_faillock.so  preauth
  -auth     [success=2 default=ignore]  pam_systemd_home.so
  auth      [success=1 default=bad]     pam_unix.so      try_first_pass nullok
  auth      [default=die]               pam_faillock.so  authfail
  auth      optional                    pam_permit.so
  auth      required                    pam_env.so
  auth      required                    pam_faillock.so  authsucc
  account   include                     system-local-login
  PAM
  echo 'auth required pam_u2f.so' | sudo tee /etc/pam.d/hyprlock-u2f
  ```
