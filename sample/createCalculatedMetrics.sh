#!/bin/bash

DT_TENANT=$(cat ../common/creds_dt.json | jq -r '.dynatraceTenant')
DT_API_TOKEN=$(cat ../common/creds_dt.json | jq -r '.dynatraceApiToken')
TAG_CONTEXT=CONTEXTLESS
TAG_KEY=keptn_project
TAG_VALUE=simpleproject

## createCalculatedMetric(METRICKEY, METRICNAME, BASEMETRIC)
# Example: createCalculatedMetric("calc:service.topurlresponsetime", "Top URL Response Time", "RESPONSE_TIME", "CONTEXTLESS", "keptn_project", "simpleproject", "URL", "{URL}")
function createCalculatedMetric() {
    METRICKEY=$1
    METRICNAME=$2
    BASEMETRIC=$3
    CONDITION_CONTEXT=$4
    CONDITION_KEY=$5
    CONDITION_VALUE=$6
    DIMENSION_NAME=$7
    DIMENSION_DEFINTION=$8

    curl -X PUT \
        "https://$DT_TENANT/api/config/v1/customMetric/service/$METRICKEY" \
        -H 'accept: application/json; charset=utf-8' \
        -H "Authorization: Api-Token $DT_API_TOKEN" \
        -H 'Content-Type: application/json; charset=utf-8' \
        -d '{
            "tsmMetricKey": "$METRICKEY",
            "name": "$METRICNAME",
            "enabled": true,
            "metricDefinition": {
                "metric": "$BASEMETRIC",
                "requestAttribute": null
            },
            "unit": "MICRO_SECOND",
            "unitDisplayName": "",
            "conditions": [
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
                "name": "$DIMENSION_NAME",
                "dimension": "$DIMENSION_DEFINTION",
                "placeholders": [],
                "topX": 10,
                "topXDirection": "DESCENDING",
                "topXAggregation": "SUM"
            }
        }' \
        -o curloutput.txt
}

## Creates a Calculated Service Metrics calc:service.topurlresponsetime
## Metrics Id: calc:service.topurlresponsetime
## Base Metric: Response Time
## Dimension: URL
## Condition: service tag [$TAG_CONTEXT]$TAG_KEY:TAG_VALUE
createCalculatedMetric "calc:service.topurlresponsetime", "Top URL Response Time", "RESPONSE_TIME", "$TAG_CONTEXT", "$TAG_KEY", "$TAG_VALUE", "URL", "{URL}"
createCalculatedMetric "calc:service.topurlresponsetime", "Top URL Response Time", "RESPONSE_TIME", "$TAG_CONTEXT", "$TAG_KEY", "$TAG_VALUE", "URL", "{URL}"
createCalculatedMetric "calc:service.topurlresponsetime", "Top URL Response Time", "RESPONSE_TIME", "$TAG_CONTEXT", "$TAG_KEY", "$TAG_VALUE", "URL", "{URL}"
















# curl -X PUT \
#         "https://$DT_TENANT/api/config/v1/customMetric/service/calc%3Aservice.topurlresponsetime" \
#         -H 'accept: application/json; charset=utf-8' \
#         -H "Authorization: Api-Token $DT_API_TOKEN" \
#         -H 'Content-Type: application/json; charset=utf-8' \
#         -d '{
#             "tsmMetricKey": "calc:service.topurlresponsetime",
#             "name": "Top URL Response Time",
#             "enabled": true,
#             "metricDefinition": {
#                 "metric": "RESPONSE_TIME",
#                 "requestAttribute": null
#             },
#             "unit": "MICRO_SECOND",
#             "unitDisplayName": "",
#             "conditions": [
#                 {
#                 "attribute": "SERVICE_TAG",
#                 "comparisonInfo": {
#                     "type": "TAG",
#                     "comparison": "EQUALS",
#                     "value": {
#                         "context": "'$TAG_CONTEXT'",
#                         "key": "'$TAG_KEY'",
#                         "value": "'$TAG_VALUE'"
#                     },
#                     "negate": false
#                 }
#                 }
#             ],
#             "dimensionDefinition": {
#                 "name": "URL",
#                 "dimension": "{URL}",
#                 "placeholders": [],
#                 "topX": 10,
#                 "topXDirection": "DESCENDING",
#                 "topXAggregation": "SUM"
#             }
#         }' \
#         -o curloutput.txt