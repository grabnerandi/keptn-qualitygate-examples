#!/bin/bash

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
echo "============================================================="
echo "About to install the Dynatrace SLI Service 0.2.0 for keptn to talk to $DT_TENANT"
echo "============================================================="
read -rsp $'Press ctrl-c to abort. Press any key to continue...\n' -n1 key

## Install Dynatrace SLI Service
git clone --branch release-0.2.0 https://github.com/keptn-contrib/dynatrace-sli-service --single-branch
kubectl apply -f dynatrace-sli-service/deploy/