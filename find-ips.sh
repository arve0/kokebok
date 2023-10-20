#!/usr/bin/env bash
# get canditates from https://crt.sh
# JS:
# var urls = new Set($$(".outer td:nth-child(6)").flatMap(i => i.innerText.split("\n")))
# console.log(Array.from(urls).join("\n"))

urls=(*.ppe.brreg.no brreg.no)

for url in "${urls[@]}"; do
  if ips=$(dig +short "$url" | grep -vE '[a-z]' | tr -s '.' | tr '\n' ' '); then
    if [[ $ips == *" "* ]]; then
      for ip in $ips; do
        if [[ $ip != "" ]]; then
          echo "$ip -> $url"
        fi
      done
    elif [[ $ips != "" ]]; then
      echo "$ips -> $url"
    fi
  fi
done
