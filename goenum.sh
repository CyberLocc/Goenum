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

# Add the GOBIN directory to the PATH
export PATH=$PATH:$(go env GOPATH)/bin 

### Check if a URL argument is provided ### 
if [ -z "$1" ]; then
    # If not, prompt for the target URL
    read -p "Enter the target URL: " url
else
    # If provided, use the provided URL
    url="$1"
fi

### Prompt to run Amass commands ###
read -p "Do you want to run Amass commands? (y/n): " run_amass

# Set the user's home directory
user_home="$HOME"

### Create Target Directories ###
if [ ! -d "$user_home/$URL" ]; then
    mkdir -p "$user_home/Projects/$PNAME/enum/goenum/goenum/eyewitness" 2> error.log
    mkdir -p "$user_home/Projects/$PNAME/enum/goenum/goenum/wayback/params" 2> error.log
    mkdir -p "$user_home/Projects/$PNAME/enum/goenum/goenum/wayback/extensions" 2> error.log
fi
  
### Harvest subdomains with assetfinder ### 
echo "[+] Harvesting subdomains with assetfinder..." 
assetfinder "$URL" >> "~/$PNAME/enum/afassets.txt"
cat "$user_home/Projects/$PNAME/enum/goenum/goenum/afassets.txt" | grep "$URL" >> "$user_home/Projects/$PNAME/enum/goenum/goenum/subdomains.txt"
rm "$user_home/Projects/$PNAME/enum/goenum/goenum/afassets.txt"

### Prompt to run Amass commands ###
if [ "$run_amass" = "y" ]; then
    ### Harvest more subdomains with amass ### 
    echo "[+] Harvesting subdomains with Amass..." 
    amass enum -d "$URL" >> "$user_home/Projects/$PNAME/enum/goenum/goenum/aassets.txt"
    sort -u "$user_home/Projects/$PNAME/enum/goenum/goenum/aassets.txt" >> "$user_home/Projects/$PNAME/enum/goenum/goenum/subdomains.txt"
    rm "$user_home/Projects/$PNAME/enum/goenum/goenum/aassets.txt"
fi

### Probe subdomains with httprobe ###
echo "[+] Probing subdomains with httprobe..."
httprobe < "$user_home/Projects/$PNAME/enum/goenum/goenum/subdomains.txt" | sed 's/^http\(\|s\):\/\///g' > "$user_home/Projects/$PNAME/enum/goenum/goenum/active.txt"
sort -u $user_home/Projects/$PNAME/enum/goenum/goenum/active.txt > $user_home/Projects/$PNAME/enum/goenum/goenum/alive.txt
rm $user_home/Projects/$PNAME/enum/goenum/goenum/active.txt

### Subdomain takeover with Subjack ###
echo "[+] Checking for possible subdomain takeover..."
 
if [ ! -f "$URL/enum/potential_takeovers/potential_takeovers.txt" ];then
	touch $user_home/Projects/$PNAME/enum/goenum/goenum/potential_takeovers.txt
fi

subjack -w "$user_home/Projects/$PNAME/enum/goenum/goenum/subdomains.txt" -t 100 -timeout 30 -ssl -c /usr/share/subjack/fingerprints.json -v 3 -o "$user_home/Projects/$PNAME/enum/goenum/goenum/potential_takeovers.txt" >/dev/null 2>&1

### Scan subdomains with Nmap ### 
echo "[+] Scanning Domains for open ports..." 
nmap -iL "$user_home/Projects/$PNAME/enum/goenum/goenum/active.txt" -T4 -oA "$user_home/Projects/$PNAME/enum/goenum/goenum/scanned.txt" -Pn > /dev/null 2>&1

### Scraping Wayback Data ###
echo "[+] Scraping wayback data..." 
cat "$user_home/Projects/$PNAME/enum/goenum/goenum/subdomains.txt" | waybackurls >> "$user_home/Projects/$PNAME/enum/goenum/goenum/waybackurls.txt"
sort -u "$user_home/Projects/$PNAME/enum/goenum/goenum/waybackurls.txt"

### Pulling and compiling all possible params found in wayback data ###
echo "[+] Pulling and compiling all possible params found in wayback data..."
cat "$user_home/Projects/$PNAME/enum/goenum/goenum/waybackurls.txt" | grep '?*=' | cut -d '=' -f 1 | sort -u >> "$user_home/Projects/$PNAME/enum/goenum/goenum/wayback/params/wayback_params.txt"
for line in $(cat "$user_home/Projects/$PNAME/enum/goenum/goenum/wayback/params/wayback_params.txt"); do
    echo "$line="
done

### Pulling and compiling js/php/aspx/jsp/json files from wayback output ###
echo "[+] Pulling and compiling js/php/aspx/jsp/json files from wayback output..."
for line in $(cat "$user_home/Projects/$PNAME/enum/goenum/goenum/waybackurls.txt"); do
    ext="${line##*.}"
    case "$ext" in
        js)
            echo "$line" >> "$user_home/Projects/$PNAME/enum/goenum/goenum/wayback/extensions/js.txt"
            ;;
        html)
            echo "$line" >> "$user_home/Projects/$PNAME/enum/goenum/goenum/wayback/extensions/jsp.txt"
            ;;
        json)
            echo "$line" >> "$user_home/Projects/$PNAME/enum/goenum/goenum/wayback/extensions/json.txt"
            ;;
        php)
            echo "$line" >> "$user_home/Projects/$PNAME/enum/goenum/goenum/wayback/extensions/php.txt"
            ;;
        aspx)
            echo "$line" >> "$user_home/Projects/$PNAME/enum/goenum/goenum/wayback/extensions/aspx.txt"
            ;;
    esac
done

### Remove temporary files ###
[ -f "$user_home/Projects/$PNAME/enum/goenum/goenum/wayback/extensions/js1.txt" ] && rm "$user_home/Projects/$PNAME/enum/goenum/goenum/wayback/extensions/js1.txt"
[ -f "$user_home/Projects/$PNAME/enum/goenum/goenum/wayback/extensions/jsp1.txt" ] && rm "$user_home/Projects/$PNAME/enum/goenum/goenum/wayback/extensions/jsp1.txt"
[ -f "$user_home/Projects/$PNAME/enum/goenum/goenum/wayback/extensions/json1.txt" ] && rm "$user_home/Projects/$PNAME/enum/goenum/goenum/wayback/extensions/json1.txt"
[ -f "$user_home/Projects/$PNAME/enum/goenum/goenum/wayback/extensions/php1.txt" ] && rm "$user_home/Projects/$PNAME/enum/goenum/goenum/wayback/extensions/php1.txt"
[ -f "$user_home/Projects/$PNAME/enum/goenum/goenum/wayback/extensions/aspx1.txt" ] && rm "$user_home/Projects/$PNAME/enum/goenum/goenum/wayback/extensions/aspx1.txt"

### Announce Results ### 
echo "[+] Enumeration Complete" 
echo "Results @ $user_home/Projects/$PNAME/enum/goenum/goenum/"
