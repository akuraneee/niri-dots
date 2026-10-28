fish_add_path -g ~/.local/bin ~/.spicetify

if status is-interactive
    starship init fish | source

    alias ls lsd
    alias z "cd .."

    # Monitor brightness over DDC (bus 2 — LG, bus 3 — Samsung)
    alias mbs1 "ddcutil --bus 2 setvcp 10"
    alias mbs2 "ddcutil --bus 3 setvcp 10"
    alias mbsp1 "ddcutil --bus 3 setvcp 10 100 && ddcutil --bus 2 setvcp 10 70"
    alias mbsp2 "ddcutil --bus 3 setvcp 10 50 && ddcutil --bus 2 setvcp 10 30"

    alias please sudo
    alias пожалуйста sudo
    alias portage pacman
    alias poweroff "echo nuh-uuh"
    alias shutdown "echo nuh-uuh"
    alias reboot "echo nuh-uuh"
    alias fakefish "sh ~/Documents/fakefish.sh"
end
export PATH="$HOME/.local/bin:$PATH"
