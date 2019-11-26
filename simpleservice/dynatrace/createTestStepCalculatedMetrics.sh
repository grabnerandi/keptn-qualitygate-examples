#!/bin/bash

# Usage:
# ./createTestStepCalculatedMetrics.sh CONTEXTLESS keptn-project simpleproject

if [[ -z "$DT_TENANT" ]]; then
  DT_TENANT=$(cat ~/dynatrace-service/deploy/scripts/creds_dt.json | jq -r '.dynatraceTenant')
fi
if [[ -z "$DT_API_TOKEN" ]]; then
  DT_API_TOKEN=$(cat ~/dynatrace-service/deploy/scripts/creds_dt.json | jq -r '.dynatraceApiToken')
fi
if [[ -z "$DT_TENANT" || -z "$DT_API_TOKEN" ]]; then
  echo "DT_TENANT & DT_API_TOKEN MUST BE SET!!"
  exit 1
fi
CONDITION_CONTEXT=$1
CONDITION_KEY=$2
CONDITION_VALUE=$3

if [[ -z "$CONDITION_KEY" && -z "$CONDITION_VALUE" ]]; then
  echo "You have to at least specify a Tag Key or Value as a filter:"
  echo "Usage: ./createTestStepCalculatedMetrics.sh CONTEXTLESS keptn-project simpleproject"
  exit 1
fi

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

echo ""
echo "Creating Metric $METRICNAME($METRICNAME)"
echo "PUT https://$DT_TENANT/api/config/v1/customMetric/service/$METRICKEY"
echo "$PAYLOAD"
curl -X PUT \
        "https://$DT_TENANT/api/config/v1/customMetric/service/$METRICKEY" \
        -H 'accept: application/json; charset=utf-8' \
        -H "Authorization: Api-Token $DT_API_TOKEN" \
        -H 'Content-Type: application/json; charset=utf-8' \
        -d "$PAYLOAD" \
        -o curloutput.txt

cat curloutput.txt
echo ""