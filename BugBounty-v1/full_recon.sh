#!/bin/bash

TARGET=$1
if [ -z "$TARGET" ]; then
  echo "Usage: $0 <domain>"
  exit 1
fi

RECON_DIR="$HOME/recon/$TARGET"
mkdir -p "$RECON_DIR"

echo "[*] Starting full recon workflow for $TARGET"

### Step 1: Basic and Advanced Recon
echo "[*] Step 1: Running recon.sh..."
./scripts/recon.sh "$TARGET"
if [ $? -ne 0 ]; then
  echo "[!] recon.sh failed. Exiting."
  exit 1
fi

### Step 2: Enrichment (whatweb, whois, ipinfo)
echo "[*] Step 2: Running enrich_info.sh..."
./scripts/enrich_info.sh "$TARGET"
if [ $? -ne 0 ]; then
  echo "[!] enrich_info.sh failed. Exiting."
  exit 1
fi

### Step 3: GF Pattern Analysis
echo "[*] Step 3: Running analyze_gf.sh..."
./scripts/analyze_gf.sh "$TARGET"
if [ $? -ne 0 ]; then
  echo "[!] analyze_gf.sh failed. Exiting."
  exit 1
fi

### Step 4: Report Generation
echo "[*] Step 4: Generating Markdown report..."
./scripts/generate_report.sh "$TARGET"
if [ $? -ne 0 ]; then
  echo "[!] generate_report.sh failed. Exiting."
  exit 1
fi

echo "[✔] All steps completed for $TARGET."
echo "[📄] Final report located at: $RECON_DIR/report.md"
