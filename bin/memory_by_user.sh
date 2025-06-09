#!/usr/bin/bash

echo "user       rss(GB) vmem(GB)";
for user in $(users | tr ' ' '\n' | sort -u); do
    ps -U $user --no-headers -o rss,vsz \
        | awk -v user=$user '{rss+=$1; vmem+=$2} END{printf("%-10s %7.1f %8.1f\n", user, rss/1024/1024, vmem/1024/1024)}'
done | sort --general-numeric-sort --key=2 --reverse
