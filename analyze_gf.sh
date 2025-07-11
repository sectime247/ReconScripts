#!/bin/bash

TARGET=$1
RESULTS_DIR="$HOME/recon/$TARGET"
OUTPUT_DIR="$RESULTS_DIR/output"
GF_DIR="$OUTPUT_DIR/gf"

mkdir -p "$GF_DIR"

echo "[*] Running gf patterns..."
for pattern in xss sqli idor lfi ssrf redirect; do
  cat "$OUTPUT_DIR/gau.txt" "$OUTPUT_DIR/wayback.txt" "$OUTPUT_DIR/katana/katana.txt" "$OUTPUT_DIR/hakrawler/hakrawler.txt" 2>/dev/null | \
  gf "$pattern" | sort -u > "$GF_DIR/$pattern.txt"
done
