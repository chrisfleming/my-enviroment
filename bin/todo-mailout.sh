#!/bin/bash

file=`mktemp`

echo "To: me@chrisfleming.org" > file
echo "Subject: Todo" >> file
$HOME/src/todo.txt-cli/todo.sh review >> file

cat file | /usr/sbin/sendmail "me@chrisfleming.org"

rm file
