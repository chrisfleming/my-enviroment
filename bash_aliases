# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias lr='ls -lr'
alias l='ls -CF'

alias p='ps -ef | grep'
alias h='history | grep'

# Clearcase alias

#checking all files
alias ctadd='cleartool lsco -cview -avobs -short | xargs cleartool ci'


alias sshtunnel='ssh -L 1993:imap.gmail.com:993 -L 1465:mail.chrisfleming.org:465 -L 3128:localhost:3128  -L 5222:talk.google.com:5222 -L 1863:messenger.hotmail.com:1863 -L 5223:chat.facebook.com:5222 -L 6667:irc.oftc.net:6667 -D 3129 shell.chrisfleming.org'

alias pasteintranet='nopaste-it -u http://chrisfl-laptop.ds.jdsu.net/pnopaste/ -n Chris'


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

# Get my IP address
function myip() {

if [ -d /Applications ]; then
  for i in `ifconfig -l`; do
    y=`ifconfig $i | awk '/inet / {split ($2,A," "); print A[1]}'`
    test "$y"  && echo $i: $y
  done
fi

if [ -d /proc ]; then
  ifconfig | awk '/inet addr/ {split ($2,A,":"); print A[2]}'
fi


}

alias syncMusic="rsync -av --exclude '.Trash-chrisfl' --exclude 'Euro Stations' -e ssh chrisfl@jeeves:/mnt/video/music/ /home/chrisfl/Music"
alias pushMusic="rsync -av --exclude '.Trash-chrisfl' --exclude 'Euro Stations' -e ssh /home/chrisfl/Music/ chrisfl@jeeves:/mnt/video/music"

