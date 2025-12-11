
if not pgrep -u (id -u) ssh-agent >/dev/null
    eval (ssh-agent -c)
end

ssh-add -l >/dev/null 2>&1
if test $status -ne 0
    ssh-add ~/.ssh/id_ed25519 >/dev/null 2>&1
end
