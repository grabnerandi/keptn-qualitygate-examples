#!/bin/bash

# Usage:
# ./createTestStepCalculatedMetrics.sh CONTEXTLESS sampleservice-hardening

DT_TENANT=$(cat ../common/creds_dt.json | jq -r '.dynatraceTenant')
DT_API_TOKEN=$(cat ../common/creds_dt.json | jq -r '.dynatraceApiToken')
CONDITION_CONTEXT=$1
CONDITION_KEY=$2
CONDITION_VALUE=$3

echo "============================================================="
echo "About to create 1 service metrics for Test Integrations [$1]$2:$3 on Dynatrace Tenant: $DT_TENANT!"
echo "============================================================="
echo "Usage: ./createTestStepCalculatedMetrics CONTEXT KEY VALUE"
read -rsp $'Press ctrl-c to abort. Press any key to continue...\n' -n1 key

METRICKEY="calc:service.teststepresponsetime"
METRICNAME="Test Step Response Time"
PAYLOAD='{
    "tsmMetricKey": "'$METRICKEY'",
    "name": "'$METRICNAME'",
    "enabled": true,
    "metricDefinition": {
        "metric": "RESPONSE_TIME",
        "requestAttribute": null
    },
    "unit": "MICRO_SECOND",
    "unitDisplayName": "",
    "conditions": [
        {
            "attribute": "SERVICE_REQUEST_ATTRIBUTE",
            "comparisonInfo": {
                "type": "STRING_REQUEST_ATTRIBUTE",
                "comparison": "EXISTS",
                "value": null,
                "negate": false,
                "requestAttribute": "TSN",
                "caseSensitive": false
            }
        },
        {
            "attribute": "SERVICE_TAG",
            "comparisonInfo": {
                "type": "TAG",
                "comparison": "EQUALS",
                "value": {
                    "context": "'$CONDITION_CONTEXT'",
                    "key": "'$CONDITION_KEY'",
                    "value": "'$CONDITION_VALUE'"
                },
                "negate": false
            }
        }
    ],
    "dimensionDefinition": {
        "name": "Test Step",
        "dimension": "{RequestAttribute:TSN}",
        "placeholders": [],
        "topX": 10,
        "topXDirection": "DESCENDING",
        "topXAggregation": "SUM"
    }
  }'

echo "Creating Metric $METRICNAME($METRICNAME)"
echo "$PAYLOAD"
curl -X PUT \
        "https://$DT_TENANT/api/config/v1/customMetric/service/$METRICKEY" \
        -H 'accept: application/json; charset=utf-8' \
        -H "Authorization: Api-Token $DT_API_TOKEN" \
        -H 'Content-Type: application/json; charset=utf-8' \
        -d "$PAYLOAD" \
        -o curloutput.txt

cat curloutput.txt