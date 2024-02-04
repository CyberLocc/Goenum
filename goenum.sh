#! /bin/bash 

cat << "EOF"

   /$$$$$$   /$$$$$$  /$$$$$$$$ /$$   /$$ /$$   /$$ /$$      /$$ 
  /$$__  $$ /$$__  $$| $$_____/| $$$ | $$| $$  | $$| $$$    /$$$ 
 | $$  \__/| $$  \ $$| $$      | $$$$| $$| $$  | $$| $$$$  /$$$$ 
 | $$ /$$$$| $$  | $$| $$$$$   | $$ $$ $$| $$  | $$| $$ $$/$$ $$ 
 | $$|_  $$| $$  | $$| $$__/   | $$  $$$$| $$  | $$| $$  $$$| $$ 
 | $$  \ $$| $$  | $$| $$      | $$\  $$$| $$  | $$| $$\  $ | $$ 
 |  $$$$$$/|  $$$$$$/| $$$$$$$$| $$ \  $$|  $$$$$$/| $$ \/  | $$ 
  \______/  \______/ |________/|__/  \__/ \______/ |__/     |__/ 

EOF

### Check for and Install Go if needed ###
set -e

GO_VERSION=$(curl -s https://golang.org/VERSION?m=text)
GO_ARCHIVE="$GO_VERSION.linux-arm64.tar.gz"
GO_LINK="https://golang.org/dl/$GO_ARCHIVE"

if ! command -v go &> /dev/null; then
    echo "Installing GoLang..."
    curl -s -o /tmp/$GO_ARCHIVE $GO_LINK
    sudo rm -rf /usr/local/go
    sudo tar -C /usr/local -xzf /tmp/$GO_ARCHIVE
    rm /tmp/$GO_ARCHIVE
fi

### Install assetfinder if needed ###
if ! command -v assetfinder &> /dev/null; then
    echo "Installing assetfinder..."
    go install github.com/tomnomnom/assetfinder@latest 
fi 

### Install amass if needed ###
if ! command -v amass &> /dev/null; then
    echo "Installing amass..."	
    go install -v github.com/owasp-amass/amass/v4/...@master 
fi 

### Install httprobe if needed ### 
if ! command -v httprobe &> /dev/null; then
    echo "Installing httprobe..."	
    go install github.com/tomnomnom/httprobe@latest 
fi 

### Install gowitness if needed ### 
if ! command -v gowitness &> /dev/null; then
    echo "Installing gowitness..."	
    go install github.com/sensepost/gowitness@latest
fi 

### Prompt for URL ###
read -p "Enter the target URL: " url

### Prompt to run Amass commands ###
read -p "Do you want to run Amass commands? (y/n): " run_amass

# Set the user's home directory
user_home="$HOME"

### Create Target Directories ###
if [ ! -d "$user_home/$url" ]; then
    mkdir -p "$user_home/$url/recon/scans" 2> error.log
    mkdir -p "$user_home/$url/recon/eyewitness" 2> error.log
    mkdir -p "$user_home/$url/recon/wayback/params" 2> error.log
    mkdir -p "$user_home/$url/recon/wayback/extensions" 2> error.log
fi

touch "$user_home/$url/recon/alive.txt"
touch "$user_home/$url/recon/subdomains.txt"

### Harvest subdomains with assetfinder ### 
echo "[+] Harvesting subdomains with assetfinder..." 
assetfinder "$url" >> "$user_home/$url/recon/afassets.txt"
cat "$user_home/$url/recon/afassets.txt" | grep "$url" >> "$user_home/$url/recon/subdomains.txt"
rm "$user_home/$url/recon/afassets.txt"

### If prompted run amass commands ###
if [ "$run_amass" = "y" ]; then
    ### Harvest more subdomains with amass ### 
    echo "[+] Harvesting subdomains with Amass..." 
    amass enum -d "$url" >> "$user_home/$url/recon/aassets.txt"
    sort -u "$user_home/$url/recon/aassets.txt" >> "$user_home/$url/recon/subdomains.txt"
    rm "$user_home/$url/recon/aassets.txt"
fi

### Probe subdomains with httprobe ###
echo "[+] Probing subdomains with httprobe..."
httprobe < "$user_home/$url/recon/subdomains.txt" | sort -u | sed 's/^http\(\|s\):\/\///g' > "$user_home/$url/recon/active.txt"

### Scan subdomains with Nmap ### 
echo "[+] Scanning Domains for open ports..." 
nmap -iL "$user_home/$url/recon/active.txt" -T4 -oA "$user_home/$url/recon/scans/scanned.txt" -Pn > /dev/null 2>&1

### Scraping Wayback Data ###
echo "[+] Scraping wayback data..." 
cat "$user_home/$url/recon/subdomains.txt" | waybackurls >> "$user_home/$url/recon/waybackurls.txt"
sort -u "$user_home/$url/recon/waybackurls.txt"

### Pulling and compiling all possible params found in wayback data ###
echo "[+] Pulling and compiling all possible params found in wayback data..."
cat "$user_home/$url/recon/waybackurls.txt" | grep '?*=' | cut -d '=' -f 1 | sort -u >> "$user_home/$url/recon/wayback/params/wayback_params.txt"
for line in $(cat "$user_home/$url/recon/wayback/params/wayback_params.txt"); do
    echo "$line="
done

### Pulling and compiling js/php/aspx/jsp/json files from wayback output ###
echo "[+] Pulling and compiling js/php/aspx/jsp/json files from wayback output..."
for line in $(cat "$user_home/$url/recon/waybackurls.txt"); do
    ext="${line##*.}"
    case "$ext" in
        js)
            echo "$line" >> "$user_home/$url/recon/wayback/extensions/js.txt"
            ;;
        html)
            echo "$line" >> "$user_home/$url/recon/wayback/extensions/jsp.txt"
            ;;
        json)
            echo "$line" >> "$user_home/$url/recon/wayback/extensions/json.txt"
            ;;
        php)
            echo "$line" >> "$user_home/$url/recon/wayback/extensions/php.txt"
            ;;
        aspx)
            echo "$line" >> "$user_home/$url/recon/wayback/extensions/aspx.txt"
            ;;
    esac
done

### Remove temporary files ###
rm "$user_home/$url/recon/wayback/extensions/js1.txt"
rm "$user_home/$url/recon/wayback/extensions/jsp1.txt"
rm "$user_home/$url/recon/wayback/extensions/json1.txt"
rm "$user_home/$url/recon/wayback/extensions/php1.txt"
rm "$user_home/$url/recon/wayback/extensions/aspx1.txt"

### Announce Results ### 
echo "[+] Enumeration Complete" 
echo "Results @ $user_home/$url/recon"


