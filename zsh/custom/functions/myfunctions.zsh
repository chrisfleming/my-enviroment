
# Search through a list of alternative binaries, returning the first match
function find_alternatives ()
{
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
}

# Add /opt/local/bin and /opt/local/sbin to path if they exsit, needed for macports and generally 
function pathadd () 
{
    if [[ -d "$1" ]]; then
        if ! echo $PATH | egrep -q "(^|:)$1($|:)" 
        then 
		    if [ "$2" = "after" ] ; then
                PATH=$PATH:$1
            else
                PATH=$1:$PATH
            fi
		fi
    fi
}


