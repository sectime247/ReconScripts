#!/bin/bash

TARGET=$1
if [ -z "$TARGET" ]; then
  echo "Usage: $0 <domain>"
  exit 1
fi

RESULTS_DIR="$HOME/recon/$TARGET"
REPORT_FILE="$RESULTS_DIR/report.md"

SUBS_FILE="$RESULTS_DIR/subdomains/subs.txt"
LIVE_FILE="$RESULTS_DIR/live/live.txt"
GAU_FILE="$RESULTS_DIR/output/gau.txt"
WAYBACK_FILE="$RESULTS_DIR/output/wayback.txt"
KATANA_FILE="$RESULTS_DIR/output/katana/katana.txt"
HAKRAWLER_FILE="$RESULTS_DIR/output/hakrawler/hakrawler.txt"
NUCLEI_FILE="$RESULTS_DIR/output/nuclei/nuclei.txt"
TRUFFLEHOG_DIR="$RESULTS_DIR/output/trufflehog"
GF_DIR="$RESULTS_DIR/output/gf"

WHATWEB_FILE="$RESULTS_DIR/enrichment/whatweb.txt"
WHOIS_FILE="$RESULTS_DIR/enrichment/whois.txt"
IPINFO_FILE="$RESULTS_DIR/enrichment/ipinfo.txt"

echo "# Recon Report for $TARGET" > "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "_Generated on $(date)_  " >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

### Subdomains
echo "## 🧭 Subdomains" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
if [ -s "$SUBS_FILE" ]; then
  wc -l < "$SUBS_FILE" | awk '{print "**Total subdomains found:**", $1}' >> "$REPORT_FILE"
  echo "" >> "$REPORT_FILE"
  head -n 10 "$SUBS_FILE" | sed 's/^/- /' >> "$REPORT_FILE"
  echo "" >> "$REPORT_FILE"
else
  echo "No subdomains found." >> "$REPORT_FILE"
  echo "" >> "$REPORT_FILE"
fi

### Live Hosts
echo "## 🟢 Live Hosts" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
if [ -s "$LIVE_FILE" ]; then
  wc -l < "$LIVE_FILE" | awk '{print "**Total live hosts:**", $1}' >> "$REPORT_FILE"
  echo "" >> "$REPORT_FILE"
  head -n 10 "$LIVE_FILE" | sed 's/^/- /' >> "$REPORT_FILE"
  echo "" >> "$REPORT_FILE"
else
  echo "No live hosts found." >> "$REPORT_FILE"
  echo "" >> "$REPORT_FILE"
fi

### Web Crawlers
echo "## 🔍 Crawled URLs" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

if [ -s "$KATANA_FILE" ]; then
  echo "**Katana:** $(wc -l < "$KATANA_FILE") URLs" >> "$REPORT_FILE"
  head -n 10 "$KATANA_FILE" | sed 's/^/- /' >> "$REPORT_FILE"
  echo "" >> "$REPORT_FILE"
fi

if [ -s "$HAKRAWLER_FILE" ]; then
  echo "**Hakrawler:** $(wc -l < "$HAKRAWLER_FILE") URLs" >> "$REPORT_FILE"
  head -n 10 "$HAKRAWLER_FILE" | sed 's/^/- /' >> "$REPORT_FILE"
  echo "" >> "$REPORT_FILE"
fi

### URL Archives
echo "## 📂 Archived URLs" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

if [ -s "$GAU_FILE" ]; then
  echo "**gau:** $(wc -l < "$GAU_FILE") URLs" >> "$REPORT_FILE"
  head -n 10 "$GAU_FILE" | sed 's/^/- /' >> "$REPORT_FILE"
  echo "" >> "$REPORT_FILE"
fi

if [ -s "$WAYBACK_FILE" ]; then
  echo "**waybackurls:** $(wc -l < "$WAYBACK_FILE") URLs" >> "$REPORT_FILE"
  head -n 10 "$WAYBACK_FILE" | sed 's/^/- /' >> "$REPORT_FILE"
  echo "" >> "$REPORT_FILE"
fi

### Vulnerabilities
echo "## 🚨 Nuclei Findings" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
if [ -s "$NUCLEI_FILE" ]; then
  wc -l < "$NUCLEI_FILE" | awk '{print "**Total issues found:**", $1}' >> "$REPORT_FILE"
  echo "" >> "$REPORT_FILE"
  head -n 10 "$NUCLEI_FILE" | sed 's/^/- /' >> "$REPORT_FILE"
  echo "" >> "$REPORT_FILE"
else
  echo "No issues found by nuclei." >> "$REPORT_FILE"
  echo "" >> "$REPORT_FILE"
fi

### Secrets
echo "## 🔑 TruffleHog Secrets" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
if [ "$(ls -A "$TRUFFLEHOG_DIR" 2>/dev/null)" ]; then
  echo "**Found potential secrets in:**" >> "$REPORT_FILE"
  for f in "$TRUFFLEHOG_DIR"/*.txt; do
    [ -s "$f" ] && echo "- $(basename "$f")" >> "$REPORT_FILE"
  done
  echo "" >> "$REPORT_FILE"
else
  echo "No secrets found by trufflehog." >> "$REPORT_FILE"
  echo "" >> "$REPORT_FILE"
fi

### GF Patterns
echo "## 📌 GF Pattern Matches" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
if [ -d "$GF_DIR" ]; then
  for f in "$GF_DIR"/*.txt; do
    name=$(basename "$f")
    count=$(wc -l < "$f")
    echo "- **$name**: $count matches" >> "$REPORT_FILE"
  done
  echo "" >> "$REPORT_FILE"
else
  echo "No GF pattern matches." >> "$REPORT_FILE"
  echo "" >> "$REPORT_FILE"
fi

### Technology & Whois
echo "## 🛠️ Technologies & Metadata" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

if [ -s "$WHATWEB_FILE" ]; then
  echo "**whatweb summary:**" >> "$REPORT_FILE"
  grep -v "^#" "$WHATWEB_FILE" | head -n 10 | sed 's/^/- /' >> "$REPORT_FILE"
  echo "" >> "$REPORT_FILE"
fi

if [ -s "$WHOIS_FILE" ]; then
  echo "<details><summary>WHOIS Info</summary>" >> "$REPORT_FILE"
  echo "" >> "$REPORT_FILE"
  cat "$WHOIS_FILE" >> "$REPORT_FILE"
  echo "</details>" >> "$REPORT_FILE"
  echo "" >> "$REPORT_FILE"
fi

if [ -s "$IPINFO_FILE" ]; then
  echo "<details><summary>IP Information</summary>" >> "$REPORT_FILE"
  echo "" >> "$REPORT_FILE"
  cat "$IPINFO_FILE" >> "$REPORT_FILE"
  echo "</details>" >> "$REPORT_FILE"
  echo "" >> "$REPORT_FILE"
fi

echo "---" >> "$REPORT_FILE"
echo "_End of report._" >> "$REPORT_FILE"

echo "[✔] Report generated at $REPORT_FILE"
