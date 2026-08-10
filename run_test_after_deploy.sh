#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

# Load local variables when the script is run from the repository.
if [[ -f "$SCRIPT_DIR/.env" ]]; then
  set -a
  # shellcheck disable=SC1091
  # Strip Windows CR characters while sourcing; keep the secret file unchanged.
  source <(sed 's/\r$//' "$SCRIPT_DIR/.env")
  set +a
fi

: "${AGENT_API_KEY:?AGENT_API_KEY is not set; export it or add it to .env}"

BASE_URL="https://agent-production-59a6.up.railway.app"

echo "1. Liveness (expected 200)"
curl -sS -i "$BASE_URL/health"

echo "2. Readiness (expected 200)"
curl -sS -i "$BASE_URL/ready"

echo "3. Missing API key (expected 401)"
curl -sS -i -X POST "$BASE_URL/ask" \
  -H "Content-Type: application/json" \
  -d '{"question":"Hello"}'

echo "4. Valid API key (expected 200)"
curl -sS -i -X POST "$BASE_URL/ask" \
  -H "Content-Type: application/json" \
  -H "X-API-Key: $AGENT_API_KEY" \
  -H "X-User-Id: sv-test" \
  -d '{"question":"Deploy là gì?"}'

echo "5. Rate limit (last requests expected 429)"
for i in $(seq 1 15); do
  curl -sS -o /dev/null -w "%{http_code} " -X POST "$BASE_URL/ask" \
    -H "Content-Type: application/json" \
    -H "X-API-Key: $AGENT_API_KEY" \
    -H "X-User-Id: sv-test" \
    -d '{"question":"test"}'
done
echo
