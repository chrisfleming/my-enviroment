
# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias lr='ls -lr'
alias l='ls -CF'

alias p='ps -ef | grep'

# Clearcase alias

#checking all files
alias ctadd='cleartool lsco -cview -avobs -short | xargs cleartool ci'


alias sshtunnel='ssh -L 1993:imap.gmail.com:993 -L 1465:mail.chrisfleming.org:465 -L 3128:localhost:3128  -L 5222:talk.google.com:5222 -L 1863:messenger.hotmail.com:1863 -L 5223:chat.facebook.com:5222 -L 6667:irc.oftc.net:6667 -D 3129 shell.chrisfleming.org'

alias vmdk_defrag_shrink='find ./ -name "*.vmdk" -print0 -exec vmware-vdiskmanager -d {} \; ; find ./ -name "*.vmdk" -print0 -exec vmware-vdiskmanager -k {} \;'

# These were going to be alias's but I ran into quoting problems so I've created functions, should move them out of this file...

# slightly nasty EPOCH to date
function epoch2date() { 
   perl -e 'use POSIX; print strftime("%a, %d %b %Y %T %z\n", localtime($ARGV[0]))' $1
}

function date2epoch() {
  perl -e 'use Time::Local;' \
       -e 'my $v = $ARGV[0] . " " . $ARGV[1];' \
       -e '($year,$month,$day,$hours,$minutes,$seconds) = $v =~ m/(\d{4})\S(\d{2})\S(\d{2})\s+(\d{2}):(\d{2}):(\d{2})/;' \
       -e '$time= timelocal($sec,$min,$hours,$day,$month,$year);' \
       -e 'print "$time\n";' $1 $2
}

function gmtime2epoch() {
  perl -e 'use Time::Local;' \
       -e 'my $v = $ARGV[0] . " " . $ARGV[1];' \
       -e '($year,$month,$day,$hours,$minutes,$seconds) = $v =~ m/(\d{4})\S(\d{2})\S(\d{2})\s+(\d{2}):(\d{2}):(\d{2})/;' \
       -e '$time= timegm($sec,$min,$hours,$day,$month,$year);' \
       -e 'print "$time\n";' $1 $2
}

# Calculator
function ccc() {

bc << EOF
scale=4
$@
quit
EOF

}

alias syncMusic="rsync -av --exclude '.Trash-chrisfl' --exclude 'Euro Stations' -e ssh chrisfl@jeeves:/mnt/video/music/ /home/chrisfl/Music"
alias pushMusic="rsync -av --exclude '.Trash-chrisfl' --exclude 'Euro Stations' -e ssh /home/chrisfl/Music/ chrisfl@jeeves:/mnt/video/music"

function reset_screen_title()
{
case "${TERM}" in
	screen)
		echo -ne '\033k'`hostname | cut -d . -f1`'\033\\'
		;;
esac
}

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
    return 1
}

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

# Screen can loose connections to the root ssh-agent. Either we could create and agent for
# every screen or just try and dink it out again.

find_ssh_agent()
{
    KEYS=`ssh-add -l`
    
}


function start_agent {
     echo "Initialising new SSH agent..."
     /usr/bin/ssh-agent | sed 's/^echo/#echo/' > "${SSH_ENV}"
     echo succeeded
     chmod 600 "${SSH_ENV}"
     . "${SSH_ENV}" > /dev/null
     /usr/bin/ssh-add;
}


