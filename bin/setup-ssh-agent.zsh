#/usr/bin/env zsh

# Search through a list of alternative binaries, returning the first match
function find_alternatives() {
    for arg in "$@"
    do
        # --skip-alias only works with GNU which
        # file=`which --skip-alias $arg 2> /dev/null`
        file=`which $arg 2> /dev/null`
        if [ -x "$file" ]; then
            echo "$file"
            return
        fi
    done
    return 1
}


# Figure out the SHORT hostname
if [[ "$OSTYPE" = darwin* ]]; then
  # macOS's $HOST changes with dhcp, etc. Use ComputerName if possible.
  SHORT_HOST=$(scutil --get ComputerName 2>/dev/null) || SHORT_HOST="${HOST/.*/}"
else
  SHORT_HOST="${HOST/.*/}"
fi

if find_alternatives ssh-agent > /dev/null; then
  zstyle :omz:plugins:ssh-agent identities `ls ~/.ssh/id* | grep -v -E '\.[a-z]{3}$'`
  source ~/.oh-my-zsh/plugins/ssh-agent/ssh-agent.plugin.zsh
fi
