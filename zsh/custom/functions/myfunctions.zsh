
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

# Get my IP address
function myip() {

blacklist=(sit0 lo teql0 gre0 ip6tnl0 eql)

if [ -d /Applications ]; then
  for i in `ifconfig -l`; do
    ic=`ifconfig $i`
    y=`echo $ic | awk '/inet / {split ($2,A," "); print A[1]}'`
    z=`echo $ic | awk '/inet6 / {split ($2,A," "); print A[1]}'`
	st=`echo $ic | awk '/status/ {split ($2,A,":"); print A[1]}'`

	# Are we connected
	st_out='\033[0;22m ✔\033[0;0m'
	if [[ "$st" == 'inactive' ]]; then
		st_out='\e[38;5;088m ✘\033[0;0m' 
	fi

    printf "$st_out %8s: %s \n" $i $st

    echo $y | while read ip; do
      test "$ip" && printf '         IP:   %s\n' $ip
    done

    echo $z | while read ip; do
      test "$ip" && printf '         IPv6: %s\n' $ip
    done

  done
fi

if [ -d /sys/class/net ]; then
    ls /sys/class/net | while read i; do
        if [[ -d /sys/class/net/$i && ! ${blacklist[*]} =~ $i ]]; then
	    # Are we connected
	    if grep -Fxq '1' /sys/class/net/$i/carrier 2> /dev/null; then
	        printf '\e[38;5;022m ✔\033[0;0m %8s:\n' $i
	    else
                printf '\e[38;5;088m ✘\033[0;0m %8s:\n' $i
	    fi

	    y=`ifconfig $i | awk '/inet addr/ {split ($2,A,":"); print A[2]}'`
	    z=`ifconfig $i | awk '/inet6 addr/ {split ($2,A,":"); print A[2]}'`

	    echo $y | while read ip; do
    	        test "$ip" && printf '         IP:   %s\n' $ip
	    done

	    echo $z | while read ip; do
	        test "$ip" && printf '         IPv6: %s\n' $ip
	    done
	
        fi
    done
fi





}


