#!/bin/bash

DT_TENANT=$(cat creds_dt.json | jq -r '.dynatraceTenant')
DT_API_TOKEN=$(cat creds_dt.json | jq -r '.dynatraceApiToken')

echo "============================================================="
echo "About to install the Dynatrace SLI Service 0.2.0 for keptn to talk to $DT_TENANT"
echo "============================================================="
read -rsp $'Press ctrl-c to abort. Press any key to continue...\n' -n1 key

## Install Dynatrace SLI Service
git clone --branch release-0.2.0 https://github.com/keptn-contrib/dynatrace-sli-service --single-branch
kubectl apply -f dynatrace-sli-service/deploy/