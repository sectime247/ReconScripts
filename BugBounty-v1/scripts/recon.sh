#!/bin/bash

TARGET=$1
if [ -z "$TARGET" ]; then
  echo "Usage: $0 <domain>"
  exit 1
fi

# Directories
RESULTS_DIR="$HOME/recon/$TARGET"
SUBS_DIR="$RESULTS_DIR/subdomains"
LIVE_DIR="$RESULTS_DIR/live"
OUTPUT_DIR="$RESULTS_DIR/output"
GF_DIR="$OUTPUT_DIR/gf"
KATANA_DIR="$OUTPUT_DIR/katana"
HAKRAWLER_DIR="$OUTPUT_DIR/hakrawler"
TRUFFLEHOG_DIR="$OUTPUT_DIR/trufflehog"
NUCLEI_DIR="$OUTPUT_DIR/nuclei"
DNSX_DIR="$OUTPUT_DIR/dnsx"

mkdir -p "$SUBS_DIR" "$LIVE_DIR" "$OUTPUT_DIR" "$GF_DIR" "$KATANA_DIR" "$HAKRAWLER_DIR" "$TRUFFLEHOG_DIR" "$NUCLEI_DIR" "$DNSX_DIR"

echo "[*] Recon started for $TARGET"

### Subdomain Enumeration ###
if [ ! -s "$SUBS_DIR/subs.txt" ]; then
  echo "[*] Running subfinder..."
  subfinder -d "$TARGET" -silent > "$SUBS_DIR/subfinder.txt"

  echo "[*] Running assetfinder..."
  assetfinder --subs-only "$TARGET" > "$SUBS_DIR/assetfinder.txt"

  echo "[*] Running amass..."
  amass enum -passive -d "$TARGET" > "$SUBS_DIR/amass.txt"

  # Chaos
  if [ -f "$HOME/.config/chaos/config.yaml" ]; then
    echo "[*] Running chaos..."
    chaos -d "$TARGET" -silent -o "$SUBS_DIR/chaos.txt"
  else
    echo "[!] Chaos config not found. Skipping chaos."
  fi

  # Findomain
  if command -v findomain &> /dev/null; then
    echo "[*] Running findomain..."
    findomain -t "$TARGET" -q > "$SUBS_DIR/findomain.txt"
  else
    echo "[!] Findomain not found. Skipping findomain."
  fi

  cat "$SUBS_DIR"/*.txt | sort -u > "$SUBS_DIR/subs.txt"
fi

### Live Host Discovery ###
if [ ! -s "$LIVE_DIR/live.txt" ]; then
  echo "[*] Checking live hosts with httpx..."
  cat "$SUBS_DIR/subs.txt" | httpx -silent > "$LIVE_DIR/live.txt"
fi

### URL Collection ###
if [ ! -s "$OUTPUT_DIR/gau.txt" ]; then
  echo "[*] Running gau..."
  cat "$LIVE_DIR/live.txt" | sed 's|^https\?://||' | gau > "$OUTPUT_DIR/gau.txt"
fi

if [ ! -s "$OUTPUT_DIR/wayback.txt" ]; then
  echo "[*] Running waybackurls..."
  cat "$SUBS_DIR/subs.txt" | waybackurls > "$OUTPUT_DIR/wayback.txt"
fi

### Crawling ###
if [ ! -s "$KATANA_DIR/katana.txt" ]; then
  echo "[*] Running katana..."
  katana -list "$LIVE_DIR/live.txt" -silent > "$KATANA_DIR/katana.txt"
fi

if [ ! -s "$HAKRAWLER_DIR/hakrawler.txt" ]; then
  echo "[*] Running hakrawler..."
  cat "$LIVE_DIR/live.txt" | hakrawler -d 2 -u -subs > "$HAKRAWLER_DIR/hakrawler.txt"
fi

### DNSX ###
if [ ! -s "$DNSX_DIR/dnsx.txt" ]; then
  echo "[*] Running dnsx..."
  cat "$SUBS_DIR/subs.txt" | dnsx -silent -a -aaaa -cname -ns -mx -ptr -txt > "$DNSX_DIR/dnsx.txt"
fi

### Vulnerability Scanning ###
if [ ! -s "$NUCLEI_DIR/nuclei.txt" ]; then
  echo "[*] Running nuclei..."
  nuclei -l "$LIVE_DIR/live.txt" \
    -t "$HOME/.local/nuclei-templates" \
    -tags "cves,xss,ssl,misconfig,exposures" \
    -o "$NUCLEI_DIR/nuclei.txt" \
    -silent
fi

### Secret Detection ###
if [ ! -d "$TRUFFLEHOG_DIR" ] || [ -z "$(ls -A $TRUFFLEHOG_DIR)" ]; then
  echo "[*] Running trufflehog..."
  for url in $(cat "$LIVE_DIR/live.txt"); do
    clean_name=$(echo "$url" | sed 's|https\?://||;s|/|_|g')
    trufflehog filesystem --path "$url" --no-update > "$TRUFFLEHOG_DIR/$clean_name.txt" 2>/dev/null
  done
fi

echo "[✔] Recon completed for $TARGET"
