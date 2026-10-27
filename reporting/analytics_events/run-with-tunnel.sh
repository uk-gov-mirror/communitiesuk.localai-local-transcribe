#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: $0 [--environment <env>] [--local-port <port>]"
  echo ""
  echo "  Opens the DB tunnel (connect-to-aws-db.sh --tunnel-only), runs the analytics_events"
  echo "  export against it, then closes the tunnel."
  echo ""
  echo "  --environment  Environment name (default: production)"
  echo "  --local-port   Local port for the tunnel (default: 5433)"
  exit 1
}

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
ENVIRONMENT="production"
LOCAL_PORT="5433"

while [[ $# -gt 0 ]]; do
  case $1 in
    --environment) [[ $# -ge 2 ]] || usage; ENVIRONMENT="$2"; shift 2 ;;
    --local-port)  [[ $# -ge 2 ]] || usage; LOCAL_PORT="$2"; shift 2 ;;
    --help|-h)     usage ;;
    *)             usage ;;
  esac
done

# shellcheck source=../_tunnel_lib.sh
source "$ROOT/reporting/_tunnel_lib.sh"
open_tunnel_and_export_env

cd "$ROOT"
poetry run python -m reporting.analytics_events

echo "" >&2
echo "Export contains real user/organisation data. Once you're done with it, delete with:" >&2
echo "  reporting/analytics_events/clear-output.sh" >&2
