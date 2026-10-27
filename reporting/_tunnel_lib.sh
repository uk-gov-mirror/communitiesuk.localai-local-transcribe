# Shared tunnel setup, sourced (not executed) by each reporting package's run-with-tunnel.sh.
#
# Callers must set $ENVIRONMENT and $LOCAL_PORT before sourcing this file, then call
# open_tunnel_and_export_env. $ROOT must point at the repo root (used to locate connect-to-aws-db.sh).
#
# Opens an SSM port-forwarding tunnel to the RDS database (connect-to-aws-db.sh --tunnel-only),
# waits for it to become ready, then exports POSTGRES_*/RDS_CA_BUNDLE_PATH so that
# common.settings can connect through it. The tunnel is torn down automatically on exit.

open_tunnel_and_export_env() {
  local region="eu-west-2"

  # Tunnel output goes to stderr so stdout stays clean for the command we eventually run.
  "$ROOT/connect-to-aws-db.sh" --environment "$ENVIRONMENT" --local-port "$LOCAL_PORT" --tunnel-only >&2 &
  # Not `local`: the EXIT trap fires after this function returns, when its local scope is gone.
  tunnel_pid=$!
  cleanup() {
    kill "$tunnel_pid" 2>/dev/null || true
    wait "$tunnel_pid" 2>/dev/null || true
  }
  trap cleanup EXIT

  for _ in $(seq 1 60); do
    kill -0 "$tunnel_pid" 2>/dev/null || { echo "Error: tunnel exited before opening." >&2; exit 1; }
    (exec 3<>"/dev/tcp/127.0.0.1/${LOCAL_PORT}") 2>/dev/null && break
    sleep 1
  done
  (exec 3<>"/dev/tcp/127.0.0.1/${LOCAL_PORT}") 2>/dev/null || { echo "Error: tunnel not ready after 60s." >&2; exit 1; }

  local rds_host rds_db
  read -r rds_host rds_db < <(aws rds describe-db-instances --region "$region" \
    --db-instance-identifier "${ENVIRONMENT}-database" \
    --query "DBInstances[0].[Endpoint.Address,DBName]" --output text)

  export ENVIRONMENT AWS_REGION="$region"
  # Stop the root .env's placeholder AWS keys (loaded by common.settings) overriding the SSO session.
  export AWS_ACCESS_KEY_ID="" AWS_SECRET_ACCESS_KEY="" AWS_SESSION_TOKEN=""
  export POSTGRES_HOST="${POSTGRES_HOST:-$rds_host}"
  export POSTGRES_DB="${POSTGRES_DB:-${rds_db/None/postgres}}"
  export POSTGRES_USER="${POSTGRES_USER:-postgres}"
  export POSTGRES_HOSTADDR=127.0.0.1 POSTGRES_PORT="$LOCAL_PORT" POSTGRES_IAM_PORT=5432
  export RDS_CA_BUNDLE_PATH="${RDS_CA_BUNDLE_PATH:-${XDG_CACHE_HOME:-$HOME/.cache}/local-transcribe/rds-ca-bundle-${region}.pem}"
}
