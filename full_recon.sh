#!/bin/bash

TARGET=$1
if [ -z "$TARGET" ]; then
  echo "Usage: $0 <domain>"
  exit 1
fi

echo "[+] Starting full recon for: $TARGET"
./recon.sh "$TARGET"
./analyze_gf.sh "$TARGET"
./enrich_info.sh "$TARGET"
./generate_report.sh "$TARGET"
