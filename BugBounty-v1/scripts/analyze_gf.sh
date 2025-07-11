#!/bin/bash

TARGET=$1
if [ -z "$TARGET" ]; then
  echo "Usage: $0 <domain>"
  exit 1
fi

OUTPUT_DIR="$HOME/recon/$TARGET/output"
GF_DIR="$OUTPUT_DIR/gf"
URLS_FILE="$OUTPUT_DIR/gau.txt"

mkdir -p "$GF_DIR"

echo "[*] Analyzing URLs with GF patterns..."

declare -a PATTERNS=("xss" "sqli" "lfi" "rce" "redirect" "idor" "ssrf" "interesting")

for pattern in "${PATTERNS[@]}"; do
  OUTPUT_FILE="$GF_DIR/$pattern.txt"
  if [ ! -s "$OUTPUT_FILE" ]; then
    echo "[*] Running gf $pattern..."
    gf "$pattern" < "$URLS_FILE" | sort -u > "$OUTPUT_FILE"
  fi
done

echo "[✔] GF analysis complete. Results saved in $GF_DIR/"
