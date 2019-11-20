#!/bin/bash

DT_TENANT=$(cat creds_dt.json | jq -r '.dynatraceTenant')
DT_API_TOKEN=$(cat creds_dt.json | jq -r '.dynatraceApiToken')

## Install Dynatrace SLI Service
# TODO: fix branch upon 0.6release
git clone --branch develop https://github.com/keptn-contrib/dynatrace-sli-service --single-branch
kubectl apply -f dynatrace-sli-service/deploy/