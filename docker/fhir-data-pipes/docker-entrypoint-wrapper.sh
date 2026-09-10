#!/bin/bash
set -euo pipefail
trap 'echo "[wrapper] Error on line ${LINENO}: ${BASH_COMMAND}" >&2' ERR

# --- 1. Function Definitions (Must come first) ---

resolve_fhir_url() {
  if [ -n "${FHIR_SERVER_URL:-}" ]; then
    echo "$FHIR_SERVER_URL"
    return 0
  fi
  if [ -f "/app/config/application.yaml" ]; then
    # Read fhirServerUrl: value (handles quoted or unquoted)
    local url
    url=$(grep -E '^\s*fhirServerUrl\s*:\s*' /app/config/application.yaml | sed -E 's/^\s*fhirServerUrl\s*:\s*\"?([^\"]*)\"?.*$/\1/' | tail -n1 || true)
    if [ -n "$url" ]; then
      echo "$url"
      return 0
    fi
  fi
  return 1
}

append_metadata() {
  local base="$1"
  if echo "$base" | grep -qE '/metadata($|[/?])'; then
    echo "$base"
    return 0
  fi
  if echo "$base" | grep -qE '/$'; then
    echo "${base}metadata"
  else
    echo "${base}/metadata"
  fi
}

wait_for_fhir() {
  local url="$1"
  local md
  md=$(append_metadata "$url")
  echo "[wrapper] Waiting for FHIR server: $md (timeout=${WAIT_FOR_FHIR_TIMEOUT}s, interval=${WAIT_FOR_FHIR_INTERVAL}s)"
  local deadline=$(( $(date +%s) + WAIT_FOR_FHIR_TIMEOUT ))
  local curl_opts=("--silent" "--show-error" "--fail" "--max-time" "5")
  if [ "$WAIT_FOR_FHIR_INSECURE" = "true" ]; then
    curl_opts+=("-k")
  fi
  while true; do
    if curl "${curl_opts[@]}" "$md" > /dev/null 2>&1; then
      echo "[wrapper] FHIR server is reachable."
      return 0
    fi
    if [ $(date +%s) -ge $deadline ]; then
      echo "[wrapper] Timed out waiting for FHIR server at $md" >&2
      return 1
    fi
    sleep "$WAIT_FOR_FHIR_INTERVAL"
  done
}

# --- 2. Main Execution Block ---

echo "[wrapper] Starting FHIR Data Pipes container..." >&2

# Compose a partitioned central sink URL when base + partition are set and
# SINK_FHIR_SERVER_URL is not already provided.
# HAPI request-tenant URLs are /fhir/{partitionName} (tenant after /fhir).
# Example: SINK_FHIR_BASE_URL=https://central-hapi:8080/fhir FHIR_SINK_PARTITION_NAME=lis1
#       -> SINK_FHIR_SERVER_URL=https://central-hapi:8080/fhir/lis1
if [ -z "${SINK_FHIR_SERVER_URL:-}" ] \
  && [ -n "${SINK_FHIR_BASE_URL:-}" ] \
  && [ -n "${FHIR_SINK_PARTITION_NAME:-}" ]; then
  sink_base="${SINK_FHIR_BASE_URL%/}"
  # Allow host-only base (…:8080) or FHIR base (…:8080/fhir)
  case "${sink_base}" in
    */fhir) export SINK_FHIR_SERVER_URL="${sink_base}/${FHIR_SINK_PARTITION_NAME}" ;;
    *)      export SINK_FHIR_SERVER_URL="${sink_base}/fhir/${FHIR_SINK_PARTITION_NAME}" ;;
  esac
  echo "[wrapper] Composed SINK_FHIR_SERVER_URL=${SINK_FHIR_SERVER_URL}" >&2
elif [ -n "${SINK_FHIR_SERVER_URL:-}" ]; then
  echo "[wrapper] Using SINK_FHIR_SERVER_URL=${SINK_FHIR_SERVER_URL}" >&2
fi

# Run environment variable substitution
if ! /app/substitute-envs.sh; then
  echo "[wrapper] substitute-envs.sh failed with exit code $?" >&2
  exit 1
fi

# Configurable variables
WAIT_FOR_FHIR=${WAIT_FOR_FHIR:-true}
WAIT_FOR_FHIR_TIMEOUT=${WAIT_FOR_FHIR_TIMEOUT:-300}
WAIT_FOR_FHIR_INTERVAL=${WAIT_FOR_FHIR_INTERVAL:-5}
WAIT_FOR_FHIR_INSECURE=${WAIT_FOR_FHIR_INSECURE:-true}
IMPORT_FHIR_CERT=${IMPORT_FHIR_CERT:-true}
FHIR_SERVER_URL_TLS=${FHIR_SERVER_URL_TLS:-""}

# A. Resolve the primary FHIR URL
FHIR_SERVER_URL=$(resolve_fhir_url || echo "")

# B. Handle Waiting logic
if [ "$WAIT_FOR_FHIR" = "true" ] && [ -n "$FHIR_SERVER_URL" ]; then
    if ! wait_for_fhir "$FHIR_SERVER_URL"; then
      echo "[wrapper] FHIR server not reachable; exiting." >&2
      exit 1
    fi
fi

# C. Fetch and Import the Certificate using the TLS URL
if [ "$IMPORT_FHIR_CERT" = "true" ] && [ -n "$FHIR_SERVER_URL_TLS" ]; then
    echo "[wrapper] Using FHIR_SERVER_URL_TLS to fetch public key..."
    
    # Extract host and port (e.g., fhir.openelis.org:8443)
    # Using python-style split logic in sed to be safe
    tls_host_port=$(echo "$FHIR_SERVER_URL_TLS" | sed -E 's|https?://([^/]+).*|\1|')
    
    # Default to 443 if no port is provided
    [[ "$tls_host_port" != *:* ]] && tls_host_port="${tls_host_port}:443"

    echo "[wrapper] Extracting cert from $tls_host_port"
    if openssl s_client -showcerts -connect "$tls_host_port" </dev/null 2>/dev/null | openssl x509 -outform PEM > /tmp/fhir_server.crt; then
        echo "[wrapper] Certificate fetched. Importing into Java Truststore..."
        keystore_path="${JAVA_HOME}/lib/security/cacerts"
        alias_name="fhir_server_auto"

        # Make this idempotent on restarts: replace existing alias if present.
        if keytool -list -keystore "$keystore_path" -storepass changeit -alias "$alias_name" >/dev/null 2>&1; then
          echo "[wrapper] Existing cert alias '$alias_name' found; replacing."
          keytool -delete -alias "$alias_name" -keystore "$keystore_path" -storepass changeit
        fi

        keytool -import -trustcacerts -alias "$alias_name" -keystore "$keystore_path" \
                -file /tmp/fhir_server.crt -storepass changeit -noprompt
        echo "[wrapper] Successfully imported certificate."
    else
        echo "[wrapper] WARNING: Could not fetch certificate from $tls_host_port. Data load might fail." >&2
    fi
fi

echo "[wrapper] Executing original /docker-entrypoint.sh" >&2
exec /docker-entrypoint.sh "$@"