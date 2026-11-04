#!/usr/bin/env bash
# Remove any asdf entries from PATH so the system python is used.
# Must be sourced to affect the current shell (bash or zsh):
#   source bin/remove-asdf-path.sh

_new_path=$(printf '%s' "$PATH" | sed -e 's#[^:]*\.asdf[^:]*##g' -e 's#::*#:#g' -e 's#^:##' -e 's#:$##')
export PATH="$_new_path"
unset _new_path
hash -r 2>/dev/null

echo "python is now: $(command -v python3)"
