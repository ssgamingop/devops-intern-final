#!/usr/bin/env bash

set -euo pipefail

echo "Current user: $(whoami)"
echo "Current date: $(date)"
echo
echo "Disk usage:"
df -h

