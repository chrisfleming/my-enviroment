if status is-interactive
# Commands to run in interactive sessions can go here
  bind delete backward-delete-char
  keychain --eval id_rsa id_ed25519 id_sftp | source
end
