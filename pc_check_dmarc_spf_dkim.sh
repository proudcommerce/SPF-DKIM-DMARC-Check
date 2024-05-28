#!/bin/bash
#
# pc_check_dmarc_spf_dkim.sh
#
# Copyright (c) 2024 Proud Commerce GmbH
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# set up your domains here
domains=(
    "google.de"
    "facebook.com"
)

# default dkim selectors
dkim_selectors=("dkim" "dkim1" "dkim2" "default" "defaultdkim" "mxvault" "k1" "k2" "eversrv" "everlytickey1" "everlytickey2" "google" "google1" "google2" "selector" "selector1" "selector2" "crsend" "mail" "mail1" "mail2" "defaultmail" "email" "email1" "email2" "smtp" "server1" "server2" "mx1" "mx2" "signing" "key1" "key2" "2022" "2023" "2024" "office365")

output_file="pc_check_dmarc_spf_dkim.csv"
echo "Domain,DMARC,SPF,DKIM" > "$output_file"

for domain in "${domains[@]}"; do
    
    dmarc_record=$(dig txt _dmarc."$domain" +short | awk -F '"' '/v=DMARC/ {print $2}' | tr -d "\n")
    
    spf_record=$(dig txt "$domain" +short | awk -F '"' '/v=spf/ {print $2}' | tr -d "\n")
    
    dkim_records=""
    for selector in "${dkim_selectors[@]}"; do
        record=$(dig txt "$selector._domainkey.$domain" +short | tr -d "\n")
        if [ ! -z "$record" ]; then
            dkim_records+="$selector=$record; "
        fi
    done
    dkim_records=$(echo "$dkim_records" | sed 's/; $//')

    echo "\"$domain\",\"$dmarc_record\",\"$spf_record\",\"$dkim_records\"" >> "$output_file"
    
done

echo "Done! See $output_file."

