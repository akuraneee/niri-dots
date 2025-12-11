
set -x GPG_TTY (tty)
if not pgrep gpg-agent >/dev/null
    gpgconf --launch gpg-agent
end
