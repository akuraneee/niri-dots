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

## Dependencies

```bash
sudo pacman -S stow niri xwayland-satellite xdg-desktop-portal-gnome xdg-desktop-portal-gtk \
    waybar swaync awww hyprlock hypridle fuzzel ghostty fish starship lsd fastfetch \
    polkit-gnome gnome-keyring network-manager-applet blueman copyq wl-clipboard \
    pavucontrol playerctl ddcutil brightnessctl power-profiles-daemon nautilus adw-gtk-theme
```

```bash
yay -S waypaper normcap
```

You also need any [Nerd Font](https://www.nerdfonts.com/), otherwise icons in waybar and fastfetch won't render.

Apps bound to hotkeys (install what you use): `helium-browser-bin`, `spotify`, `discord`, `keepassxc`,
and the flatpaks `md.obsidian.Obsidian` and `org.telegram.desktop`.

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

## Notes

- Outputs are set up for my monitors (`DP-1` + `HDMI-A-1`). Edit the "Outputs" section in `niri/.config/niri/config.kdl`; get your output names from `niri msg outputs`.
- After editing the niri config, run `niri validate`.
- To show an avatar on the lock screen, put an image at `~/.face`.
- Idle: unlocked — suspend after 15 min; locked — monitors off after 30 s, suspend after 5 min.
  Waking up always lands on the lock screen. Timings live in `hypr/.config/hypr/hypridle.conf`.
