# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

alias sshtunnel='ssh -L 1993:imap.gmail.com:993 -L 1465:mail.chrisfleming.org:465 -L 3128:localhost:3128  -L 5222:talk.google.com:5222 -L 1863:messenger.hotmail.com:1863 -L 5223:chat.facebook.com:5222 -L 6667:irc.oftc.net:6667 shell.chrisfleming.org'

# http://dsg.bei.ds.jdsu.net/cgi-bin/lsload/lsload.pl?location=BEJ

alias sshbeisles9-1='ssh fle56202@beisles9i32-1.bei.ds.jdsu.net'
alias sshbeisles9-2='ssh fle56202@beisles9i32-2.bei.ds.jdsu.net'
alias sshbeisles10-1='ssh fle56202@beisles10i32-1.bei.ds.jdsu.net'
alias sshbeisles10-2='ssh fle56202@beisles10i32-2.bei.ds.jdsu.net'
alias sshbeisles10-3='ssh fle56202@beisles10i32-3.bei.ds.jdsu.net'

alias pasteintranet='nopaste-it -u http://chrisfl-laptop.ds.jdsu.net/pnopaste/ -n Chris'

# slightly nasty EPOCH to date
function epoch2date() { 
   perl -e '($sec,$min,$hour,$day,$month,$year)= localtime($ARGV[0]); printf "%02d/%02d/%02d %02d:%02d:%02d\n", $year +1900, $month++, $day, $hour, $min, $sec;' $1

}

alias syncMusic="rsync -av --exclude '.Trash-chrisfl' --exclude 'Euro Stations' -e ssh chrisfl@jeeves:/mnt/video/music/ /home/chrisfl/Music"
alias pushMusic="rsync -av --exclude '.Trash-chrisfl' --exclude 'Euro Stations' -e ssh /home/chrisfl/Music/ chrisfl@jeeves:/mnt/video/music"

