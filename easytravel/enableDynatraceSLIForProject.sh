#!/bin/bash
kubectl apply -f lighthouse_source_dynatrace.yaml
## Create Global Dynatrace SLI Secret
echo "DT_TENANT: $DT_TENANT" \
     "DT_API_TOKEN: $DT_API_TOKEN" > dynatrace_secret.yaml

kubectl create secret generic dynatrace-credentials-sample -n "keptn" --from-file=dynatrace-credentials=dynatrace_secret.yaml

rm dynatrace_secret.yaml
