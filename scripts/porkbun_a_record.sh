#!/usr/bin/env bash
# Idempotently ensure the A record for PORKBUN_DOMAIN -> PORKBUN_CONTENT
# exists in Porkbun. Values are passed via environment variables from the
# Terraform local-exec provisioner.
set -euo pipefail

: "${PORKBUN_API_BASE:?PORKBUN_API_BASE is required}"
: "${PORKBUN_DOMAIN:?PORKBUN_DOMAIN is required}"
: "${PORKBUN_CONTENT:?PORKBUN_CONTENT is required}"
: "${PORKBUN_API_KEY:?PORKBUN_API_KEY is required}"
: "${PORKBUN_SECRET_KEY:?PORKBUN_SECRET_KEY is required}"

# ------------------------------------------------
echo ">> Pinging Porkbun API"
curl -fsS -H "Content-Type: application/json" \
     -d "{\"apikey\":\"$PORKBUN_API_KEY\",\"secretapikey\":\"$PORKBUN_SECRET_KEY\"}" \
     "$PORKBUN_API_BASE/ping" >/dev/null

# ------------------------------------------------
# Try to create the record. Porkbun returns:
#   - HTTP 200 + {"status":"SUCCESS",...} when the record is created
#   - HTTP 400 with a "There was a problem" body when it already exists
# Both are acceptable for an idempotent apply.
BODY=$(mktemp)
trap 'rm -f "$BODY" "$BODY.out"' EXIT
cat > "$BODY" <<JSON
{
  "apikey":        "$PORKBUN_API_KEY",
  "secretapikey":  "$PORKBUN_SECRET_KEY",
  "name":          "@",
  "type":          "A",
  "content":       "$PORKBUN_CONTENT",
  "ttl":           "600",
  "notes":         "A Record for vultr instance root domain"
}
JSON
echo ">> Creating A record for $PORKBUN_DOMAIN -> $PORKBUN_CONTENT"
HTTP_CODE=$(curl -X POST -sS -o "$BODY.out" -w "%{http_code}" \
  -H "Content-Type: application/json" \
  -d @"$BODY" \
  "$PORKBUN_API_BASE/dns/create/$PORKBUN_DOMAIN")
mv "$BODY.out" "$BODY"
echo "HTTP $HTTP_CODE"
cat "$BODY"; echo

case "$HTTP_CODE" in
  200) echo ">> Record created" ;;
  400) echo ">> Record already exists (or other 400) - treating as success" ;;
  *)   echo ">> Unexpected HTTP $HTTP_CODE from Porkbun" >&2; exit 1 ;;
esac

# ------------------------------------------------
# Try to create the record. Porkbun returns:
#   - HTTP 200 + {"status":"SUCCESS",...} when the record is created
#   - HTTP 400 with a "There was a problem" body when it already exists
# Both are acceptable for an idempotent apply.
BODY=$(mktemp)
trap 'rm -f "$BODY" "$BODY.out"' EXIT
cat > "$BODY" <<JSON
{
  "apikey":        "$PORKBUN_API_KEY",
  "secretapikey":  "$PORKBUN_SECRET_KEY",
  "name":          "www",
  "type":          "CNAME",
  "content":       "@",
  "ttl":           "600",
  "prio":          null,
  "notes":         "WWW CNAME to root domain"
}
JSON
echo ">> Creating CNAME record for www"
HTTP_CODE=$(curl -X POST -sS -o "$BODY.out" -w "%{http_code}" \
  -H "Content-Type: application/json" \
  -d @"$BODY" \
  "$PORKBUN_API_BASE/dns/create/$PORKBUN_DOMAIN")
mv "$BODY.out" "$BODY"
echo "HTTP $HTTP_CODE"
cat "$BODY"; echo

case "$HTTP_CODE" in
  200) echo ">> Record created" ;;
  400) echo ">> Record already exists (or other 400) - treating as success" ;;
  *)   echo ">> Unexpected HTTP $HTTP_CODE from Porkbun" >&2; exit 1 ;;
esac