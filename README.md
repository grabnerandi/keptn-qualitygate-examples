# keptn-qualitygate-examples

## Pre-Requs:
Create a Git Repo and provide Token (GIT_TOKEN) & Username (GIT_USER) and Remote Url (GIT_REMOTE_URL)

# Install Keptn Quality GAtes
installKeptnQualityGates.sh
exposeBridge.sh

# Install Dynatrace SLI Service
defineDynatraceCredentials.sh
setupDynatraceSLIService.sh

# Create Project & Service in Keptn for our sample
keptn create project sample --shipyard=./shipyard.yaml --git-user=GIT_USER --git-token=GIT_TOKEN --git-remote-url=GIT_REMOTE_URL
keptn create service sampleservice --project=sample

# add our SLOs & SLIs
kubectl apply -f sample_dynatrace_sli.yaml
keptn add-resource --project=sample --service=sampleservice --stage=hardening --resource=sample_slo.yaml --resourceUri=slo.yaml

# Execute a Quality Gate Evaluation
keptn send event start-evaluation --project=sample --service=sampleservice --stage=hardening --timeframe=5m --start=2019-11-20T11:00:00

# Wait for Quality Gate Result
keptn get event evaluation-done --keptn-context=c628051d-0d20-4024-814a-684e8ee7393f

# Expose Keptns Bridge via http://localhost:9000
kubectl port-forward svc/bridge -n keptn 9000:8080