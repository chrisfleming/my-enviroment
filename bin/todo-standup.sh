#!/bin/bash

file=`mktemp`

echo "From: me@chrisfleming.org" > $file
echo "To: chris_fleming@non.agilent.com" >> $file
echo "Subject: Todo" >> $file
$HOME/src/todo.txt-cli/todo.sh standup >> $file

cat $file | /usr/sbin/sendmail -f "me@chrisfleming.org" "chris_fleming@non.agilent.com"

echo $file
