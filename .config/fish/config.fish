#ource /usr/share/cachyos-fish-config/cachyos-config.fish
starship init fish | source

alias ls lsd
alias mbs1 "ddcutil --bus 2 set 10"
alias mbs2 "ddcutil --bus 3 set 10"
alias mbsp1 "ddcutil --bus 3 set 10 100 && ddcutil --bus 2 set 10 70"
alias mbsp2 "ddcutil --bus 3 set 10 50 && ddcutil --bus 2 set 10 30"
alias z "cd .."
alias t "tmux"
# overwrite greeting
# potentially disabling fastfetch
#function fish_greeting
#    # smth smth
set -gx PF_ASCII "arch"
# Created by `pipx` on 2025-10-15 17:40:33
set PATH $PATH /home/akurane/.local/bin

fish_add_path /home/akurane/.spicetify
