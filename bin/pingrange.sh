!/bin/bash

NETWORK=$1
START=$2
END=$3

# Print table header
printf "%-15s %-10s\n" "IP Address" "Status"
printf "%-15s %-10s\n" "----------" "------"

for i in $(seq $START $END); do
  IP="$NETWORK.$i"

  if ping -c 1 -W 1 "$IP" &>/dev/null; then
    printf "%-15s %-10s\n" "$IP" "Reachable"
  else
    printf "%-15s %-10s\n" "$IP" "Unreachable"
  fi
done
