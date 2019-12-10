#!/bin/bash

# Usage:
# Assumes KEPTN_ENDPOINT and KEPTN_API_TOKEN are set
# ./sendNewArtifactEvent.sh PROJECT SERVICE IMAGE

if [[ -z "$KEPTN_ENDPOINT" || -z "$KEPTN_API_TOKEN" ]]; then
  echo "KEPTN_ENDPOINT & KEPTN_API_TOKEN MUST BE SET!!"
  exit 1
fi

PROJECT=$1
SERVICE=$2
IMAGE=$3

if [[ -z "$PROJECT" || -z "$SERVICE" || -z "$IMAGE" ]]; then
  echo "You have to specify Project, Service & Image"
  echo "Usage: ./sendNewArtifactEvent.sh simpleproject simplenode docker.io/grabnerandi/simplenodeservice:0.3.0"
  exit 1
fi

PAYLOAD='{
  "type": "sh.keptn.event.configuration.change", 
  "specversion": "0.2", 
  "source": "GitLab CI", 
  "contenttype": "application/json", 
  "data": { 
    "canary": { 
      "action": "set", 
      "value": 100 
    }, 
    "project": "'$PROJECT'", 
    "stage": "", 
    "service": "'$SERVICE'", 
    "valuesCanary": {
      "image": "'$IMAGE'" 
    } 
  }
}'

echo "$PAYLOAD"
curl -X POST "$KEPTN_ENDPOINT/v1/event" \
     -H "accept: application/json" \
     -H "x-token: $KEPTN_API_TOKEN" \
     -H "Content-Type: application/json" \
     -d "$PAYLOAD" -o curloutput.txt -k
cat curloutput.txt
echo ""