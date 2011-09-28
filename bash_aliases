# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias lr='ls -lr'
alias l='ls -CF'

alias p='ps -ef | grep'

alias h='history | grep'

alias sshtunnel='ssh -L 1993:imap.gmail.com:993 -L 1465:mail.chrisfleming.org:465 -L 3128:localhost:3128  -L 5222:talk.google.com:5222 -L 1863:messenger.hotmail.com:1863 -L 5223:chat.facebook.com:5222 -L 6667:irc.oftc.net:6667 -D 3129 shell.chrisfleming.org'

# http://dsg.bei.ds.jdsu.net/cgi-bin/lsload/lsload.pl?location=BEJ

alias sshbeisles9-1='ssh fle56202@beisles9i32-1.bei.ds.jdsu.net'
alias sshbeisles9-2='ssh fle56202@beisles9i32-2.bei.ds.jdsu.net'
alias sshbeisles10-1='ssh fle56202@beisles10i32-1.bei.ds.jdsu.net'
alias sshbeisles10-2='ssh fle56202@beisles10i32-2.bei.ds.jdsu.net'
alias sshbeisles10-3='ssh fle56202@beisles10i32-3.bei.ds.jdsu.net'
alias sshsin3aIQc='ssh root@10.66.142.3'

alias pasteintranet='nopaste-it -u http://chrisfl-laptop.ds.jdsu.net/pnopaste/ -n Chris'

# These were going to be alias's but I ran into quoting problems so I've created functions, should move them out of this file...

# slightly nasty EPOCH to date
function epoch2date() { 
   perl -e '($sec,$min,$hour,$day,$month,$year)= localtime($ARGV[0]); printf "%02d/%02d/%02d %02d:%02d:%02d\n", $year +1900, $month++, $day, $hour, $min, $sec;' $1
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

if [ -d /sw/ ]; then
  ifconfig en0 | awk '/inet / {split ($2,A," "); print A[1]}'
fi

if [ -d /proc ]; then
  ifconfig | awk '/inet addr/ {split ($2,A,":"); print A[2]}'
fi


}
