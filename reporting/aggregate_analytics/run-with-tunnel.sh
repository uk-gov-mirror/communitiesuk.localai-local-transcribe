#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: $0 [--environment <env>] [--local-port <port>] [-- <aggregate_analytics args>]"
  echo ""
  echo "  Opens the DB tunnel (connect-to-aws-db.sh --tunnel-only), runs the aggregate analytics"
  echo "  report against it, then closes the tunnel."
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
    --)            shift; break ;;
    *)             break ;;
  esac
done

# shellcheck source=../_tunnel_lib.sh
source "$ROOT/reporting/_tunnel_lib.sh"
open_tunnel_and_export_env

cd "$ROOT"
poetry run python -m reporting.aggregate_analytics "$@"
