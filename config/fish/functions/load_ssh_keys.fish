function load_ssh_keys -d "Load SSH keys for keychain from config file"
    argparse 'f/file=' -- $argv
    
    set key_file $_flag_file
    or set key_file ~/.ssh/autoloadkeys
    
    if not test -f $key_file
        echo "No keychain key file found at $key_file" >&2
        return 1
    end
    
    set keys (cat $key_file | string trim | string match -v -r '^\s*$|^#')
    
    if test -n "$keys"
        keychain --eval $keys | source
    else
        echo "No keys found in $key_file" >&2
        return 1
    end
end
