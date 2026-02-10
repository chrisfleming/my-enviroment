#!/usr/bin/env bash

# Strict settings
set -euo pipefail
IFS=$'\n\t'

# Debugging
[[ -n "${DEBUG:-}" ]] && set -x

IP=${1:-}

if [[ -z "$IP" ]]; then
  echo "Please include the IP address"
fi
