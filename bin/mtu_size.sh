#!/bin/bash

if [ $# -ne 2 ]; then
  echo "Usage: $0 <host> <max_mtu>"
  echo "Example: $0 google.com 1500"
  exit 1
fi

myhost=$1
max_mtu=$2
min_mtu=500

# Convert to payload sizes (subtract 28 for ICMP+IP)
low=$((min_mtu - 28))
high=$((max_mtu - 28))

echo "Binary search for MTU to $myhost between $min_mtu and $max_mtu..."
echo ""

last_good=0

while [ $low -le $high ]; do
  mid=$(((low + high) / 2))
  mtu=$((mid + 28))

  # echo -n "Low: $low   High: $high  Last Good: $last_good  mid: $mid     "
  echo -n "Testing MTU $mtu bytes... "

  if ping -M do -s $mid -c 1 -W 2 $myhost >/dev/null 2>&1; then
    echo "SUCCESS"
    last_good=$mid
    low=$((mid + 1))
  else
    echo "failed"
    high=$((mid - 1))
  fi
done

if [ $last_good -gt 0 ]; then
  mtu=$((last_good + 28))
  echo ""
  echo "Maximum MTU: $mtu bytes"
  echo "Maximum MSS (no options): $((mtu - 40)) bytes"
  echo "Maximum MSS (with timestamps): $((mtu - 52)) bytes"
  exit 0
else
  echo ""
  echo "ERROR: No working MTU found. Host may be unreachable."
  exit 1
fi
