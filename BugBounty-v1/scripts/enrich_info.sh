#!/bin/bash

TARGET=$1
if [ -z "$TARGET" ]; then
  echo "Usage: $0 <domain>"
  exit 1
fi

RESULTS_DIR="$HOME/recon/$TARGET"
LIVE_FILE="$RESULTS_DIR/live/live.txt"
ENRICH_DIR="$RESULTS_DIR/enrichment"

mkdir -p "$ENRICH_DIR"

### 1. whatweb ###
WHATWEB_OUT="$ENRICH_DIR/whatweb.txt"
if [ ! -s "$WHATWEB_OUT" ]; then
  echo "[*] Running whatweb on live hosts..."
  whatweb -i "$LIVE_FILE" --log-verbose="$WHATWEB_OUT"
fi

### 2. WHOIS ###
WHOIS_OUT="$ENRICH_DIR/whois.txt"
if [ ! -s "$WHOIS_OUT" ]; then
  echo "[*] Running WHOIS for domain..."
  whois "$TARGET" > "$WHOIS_OUT" 2>/dev/null
fi

### 3. IP Info ###
IPINFO_OUT="$ENRICH_DIR/ipinfo.txt"
if [ ! -s "$IPINFO_OUT" ]; then
  echo "[*] Resolving IP and running IP whois..."
  RESOLVED_IP=$(dig +short "$TARGET" | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' | head -n 1)
  if [ -n "$RESOLVED_IP" ]; then
    echo "[*] IP: $RESOLVED_IP" > "$IPINFO_OUT"
    whois "$RESOLVED_IP" >> "$IPINFO_OUT" 2>/dev/null
  else
    echo "[!] Could not resolve IP for $TARGET" > "$IPINFO_OUT"
  fi
fi

echo "[✔] Enrichment complete. Results saved in $ENRICH_DIR/"
