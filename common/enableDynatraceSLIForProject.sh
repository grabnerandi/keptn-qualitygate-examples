#!/bin/bash

DT_TENANT=$(cat creds_dt.json | jq -r '.dynatraceTenant')
DT_API_TOKEN=$(cat creds_dt.json | jq -r '.dynatraceApiToken')

if [[ -z "$1" ]]; then
  echo "You have to specify the Project Name!"
  echo "Usage: enableDynatraceSLIForProject.sh MyKeptnProject"
  exit 1
fi

echo "============================================================="
echo "Enabling Dynatrace SLI Service for your keptn project: $1"
echo "Dynatrace SLI will pull data from Dynatrace Tenant: $DT_TENANT"
echo "Creating secret dynatrace-credentials-$1 in keptn namespace"
echo "============================================================="
read -rsp $'Press ctrl-c to abort. Press any key to continue...\n' -n1 key

###################################################################################
## The Lighthouse Service needs a ConfigMap with the name lighthouse-config-PROJECTNAME
## This ConfigMap references the SLI Provider to be used, in our case Dynatrace
###################################################################################
rm -f ./manifests/gen/lighthouse_source_dynatrace.yaml
cat ./manifests/lighthouse_source_dynatrace.yaml | \
  sed 's~PROJECT~'"$1"'~' > ./manifests/gen/lighthouse_source_dynatrace.yaml

kubectl apply -f ./manifests/gen/lighthouse_source_dynatrace.yaml

###################################################################################
## Dynatrace SLI Provider reads Dynatrace Token information from dynatrace-credentials-PROJECTNAME
###################################################################################
echo "DT_TENANT: $DT_TENANT
DT_API_TOKEN: $DT_API_TOKEN" > dynatrace_secret.yaml

kubectl create secret generic dynatrace-credentials-$1 -n "keptn" --from-file=dynatrace-credentials=dynatrace_secret.yaml

rm dynatrace_secret.yaml