#!/usr/bin/env bash
set -euo pipefail

DOMAIN="duckaregreatsoyoucanhaveone.com"
CLOUDFLARE_TOKEN="YOUR_API_TOKEN"
SERVER_IP="192.0.2.10"

zone_response=$(curl -fsS \
  "https://api.cloudflare.com/client/v4/zones?name=$DOMAIN" \
  -H "Authorization: Bearer $CLOUDFLARE_TOKEN")

zone_id=$(jq -r '.result[0].id' <<<"$zone_response")

if [[ "$zone_id" == "null" || -z "$zone_id" ]]; then
  echo "Domain zone not found in Cloudflare."
  exit 1
fi

create_record() {
  local name="$1"
  curl -fsS -X POST \
    "https://api.cloudflare.com/client/v4/zones/$zone_id/dns_records" \
    -H "Authorization: Bearer $CLOUDFLARE_TOKEN" \
    -H "Content-Type: application/json" \
    --data "$(jq -n \
      --arg name "$name" \
      --arg ip "$SERVER_IP" \
      '{type:"A", name:$name, content:$ip, ttl:1, proxied:true}')"
}

create_record "$DOMAIN"
create_record "www"

echo "A records created for $DOMAIN and www.$DOMAIN"
