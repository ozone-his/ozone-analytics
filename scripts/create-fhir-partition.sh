#!/usr/bin/env bash
# Create a HAPI FHIR request-tenant partition on a central (partitioned) server.
#
# Usage:
#   ./scripts/create-fhir-partition.sh <hapi-base-url> <partition-id> <partition-name>
#
# Examples:
#   ./scripts/create-fhir-partition.sh http://localhost:8093 1 lis1
#   ./scripts/create-fhir-partition.sh https://central-hapi.example.org 2 toamasina
#
# After creating the partition, site pipes should sink to:
#   ${SINK_FHIR_BASE_URL}/${partition-name}/fhir
set -euo pipefail

if [ "$#" -lt 3 ]; then
  echo "Usage: $0 <hapi-base-url> <partition-id> <partition-name>" >&2
  echo "Example: $0 http://localhost:8093 1 lis1" >&2
  exit 1
fi

HAPI_BASE_URL="${1%/}"
PARTITION_ID="$2"
PARTITION_NAME="$3"

# Management operation lives on the default FHIR endpoint (not under a tenant path).
OP_URL="${HAPI_BASE_URL}/fhir/\$partition-management-create-partition"

BODY=$(cat <<EOF
{
  "resourceType": "Parameters",
  "parameter": [
    { "name": "id", "valueInteger": ${PARTITION_ID} },
    { "name": "name", "valueCode": "${PARTITION_NAME}" }
  ]
}
EOF
)

echo "Creating partition id=${PARTITION_ID} name=${PARTITION_NAME} at ${OP_URL}"
HTTP_CODE=$(curl -sS -o /tmp/create-fhir-partition-response.json -w "%{http_code}" \
  -X POST "${OP_URL}" \
  -H "Content-Type: application/fhir+json" \
  -H "Accept: application/fhir+json" \
  -d "${BODY}")

echo "HTTP ${HTTP_CODE}"
cat /tmp/create-fhir-partition-response.json
echo

if [ "${HTTP_CODE}" != "200" ] && [ "${HTTP_CODE}" != "201" ]; then
  echo "Failed to create partition (HTTP ${HTTP_CODE})" >&2
  exit 1
fi

echo "Partition '${PARTITION_NAME}' ready. Site sink URL:"
echo "  ${HAPI_BASE_URL}/fhir/${PARTITION_NAME}"
