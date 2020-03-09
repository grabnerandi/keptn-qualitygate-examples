# Setting up Sample Keptn 0.6.0.beta2 Quality Gate Project for Services monitored with Dynatrace

**Disclaimer:** this is for [keptn 0.6.0.beta2](https://keptn.sh/docs/0.6.0/) "quality gates only" use case

This example walks you through 
1. Installing keptn for the capabilty **Quality Gates only** on GKE
2. Defining SLIs (Service Level Indicators) and SLOs (Service Level Objects) for metrics from Dynatrace
3. Having keptn evaluate these SLOs when calling the Keptn CLI or the Keptn CLI for a specific timeframe

The default SLI used in the sample will query 5 different metrics from a Dynatrace monitored service leveraging the new Dynatrace Metrics API.
```
  custom-queries: |
    throughput:            "builtin:service.requestCount.total:merge(0):sum?scope=tag($SERVICE-$STAGE)"
    error_rate:            "builtin:service.errors.total.count:merge(0):avg?scope=tag($SERVICE-$STAGE)"
    response_time_p50:     "builtin:service.response.time:merge(0):percentile(50)?scope=tag($SERVICE-$STAGE)"
    response_time_p90:     "builtin:service.response.time:merge(0):percentile(90)?scope=tag($SERVICE-$STAGE)"
    response_time_p95:     "builtin:service.response.time:merge(0):percentile(95)?scope=tag($SERVICE-$STAGE)"
```

Later in the tutorial we are adding some custom service metrics to this list such as
```
    rt_invoke_avg:         "calc:service.topurlresponsetime:filter(eq(URL,/api/invoke)):merge(0):avg?scope=tag($SERVICE-$STAGE)"
    count_svccalls_invoke: "calc:service.topurlservicecalls:filter(eq(URL,/api/invoke)):merge(0):sum?scope=tag($SERVICE-$STAGE)"
    count_dbcalls_invoke:  "calc:service.topurldbcalls:filter(eq(URL,/api/invoke)):merge(0):avg?scope=tag($SERVICE-$STAGE)"
```

Our sample will create a keptn service called "sampleservice" and assumes there is one stage called "hardening". These names are also used to execute the queries shown above. So - the only thing we have to do for our sample to work is to put a tag on a Dynatrace monitored service with the name "sampleservice-hardening" as shown below. For the sake of this example you can put this tag on any of your monitored services but make sure it has traffic so that we actually get some data:

![](images/sampleservice-tags-dynatrace.png)

Keptn evaluates these SLOs on demand (via CLI or API):
```
keptn send event start-evaluation --project=sample --service=sampleservice --stage=hardening --timeframe=5m
```

Results are either shown in the keptn's bridge or you can query it via the CLI or API:
![](images/evaluation-done-bridge.png)

# Pre-Requisits
## 1. GKE Cluster
While this may also work on k8s clusters we have tested this with a single n1-standard-4 node GKE 1.13 cluster.

## 2. Linux Shell
I've also used Google's Cloud Shell to execute all installation scripts. 
If you dont use Google Cloud Shell you need a linux shell with installed **kubectl**, **git**

## 3. Git Repo
Keptn installs its own Git. In order to modify SLIs & SLOs that are managed by keptn we will define a remote git upstream. Feel free to use GitHub, GitLab, Bitbucket or any other Git service. What you need are these 3 things
1. **GIT_REMOTE_URL**: Create a Remote Git Hub Repo that includes a Readme.md
2. **GIT_USER**: Your git user to login
3. **GIT_TOKEN**: A token for your git that allows keptn to push updates to that repo

In my case I simply create a GitHub repo like this:

![](images/github-repo-create.png)

## 4. Dynatrace Token
This example shows keptn quality gates based on Dynatrace metrics using the new [Dynatrace Metrics v2 API](https://www.dynatrace.com/support/help/extend-dynatrace/dynatrace-api/environment-api/metric/).
Hence you need Dynatrace that instruments the services you want to validate SLOs against. In order for keptn to automate that validation we need two things:
1. **Dynatrace URL**: Thats e.g: https://abc12345.dynatrace.live.com (for SaaS) or your https://managedservice/e/yourenvioronment (for Managed)
2. **Dynatrace API Token**: Please create a Dytrace API token with access to timeseries as well as read & write configuration (for my advanced service metric SLIs)

# 1. Installation of Keptn Quality Gates

## 1.1 Install Keptn Quality Gates on GKE

Open your Linux shell where you are connected to your GKE cluster. You can validate it by executing kubectl get nodes (but I guess you knew that already) :-)
First we download the keptn CLI (right now 0.6.0.beta2) in our home directory!
```
wget https://github.com/keptn/keptn/releases/download/0.6.0.beta2/0.6.0.beta2_keptn-linux.tar.gz
tar -xvf 0.6.0.beta2_keptn-linux.tar.gz
chmod +x keptn
mv keptn ~
rm 0.6.0.beta2_keptn-linux.tar.gz
```

Now lets install keptn with the quality gates use case only
```
~/keptn install -p=kubernetes --keptn-version=0.6.0.beta2 --use-case=quality-gates --verbose
```

In that same shell lets start by cloning this repo and execute a script I prepared that exposes the keptn's bridge:
```
git clone https://github.com/grabnerandi/keptn-qualitygate-examples
cd keptn-qualitygate-examples
cd common
./exposeBridge.sh
```
Validate Keptn install is done and successful by looking at the console output. exposeBridge.sh will expose the keptns bridge under a URL with the format https://bridge.keptn.1.2.3.4.xip.io. Should look like this:
![](images/keptn-bridge-after-install.png)

You can also validate whether you can access the API endpoint via https://api.keptn.1.2.3.4.xip.io/swagger-ui
![](images/swagger-ui.png)

You now also have the keptn CLI installed with is already authenticated against your keptn installation. You can run e.g: keptn or keptn status 
```
~/keptn
~/keptn status
```

## 1.2 Install Dynatrace SLI Service
Keptn has a central service called Lighthouse services which does all the pulling of data from different data providers (SLI providers), stores the data in the backend mongodb and also does the SLO validation based on the SLO definition. The first thing we need to do is to install the Dynatrace SLI data provider which is one of the providers currently supported!
```
./defineDynatraceCredentials.sh
./setupDynatraceSLIService.sh
```

# 2. Setup keptn project & service with SLIs & SLOs

## 2.1 Create Project & Service in Keptn for our sample
I decided to keep it simple!
We create a project with the name *sample* and it will have a service with the name *sampleservice*. The *shipyard* file defines a single stage with the name *hardening*!
Make sure you have your GIT_USER, GIT_TOKEN and GIT_REMOTE_URL ready!
```
cd ../sample
~/keptn create project sample --shipyard=./shipyard.yaml --git-user=GIT_USER --git-token=GIT_TOKEN --git-remote-url=GIT_REMOTE_URL
~/keptn create service sampleservice --project=sample
```
If you open your git repository you should already see content in the master and content in the hardening branch as keptn automatically creates branches for each stage.
![](images/github-after-createproject.png)

## 2.2 Enable Dynatrace SLI for Project
While we have installed the Dynatrace SLI Data Source for keptn we have to enable and configure it for each project. 
The enableDynatraceSLIForProjects.sh actually does two things: 
1) creates a a config map entry for the lighthouse service to know which SLI providers to use for this project and 
2) puts the previously provided Dynatrace Token and URL in a secret that the Dynatrace SLI can use to query data from Dynatrace during the actual quality gate evaluation.

Ready? lets set it up for the sample project
```
cd ../common
./enableDynatraceSLIForProject.sh sample
```

## 2.3 Adding our SLOs & SLIs
**As of keptn 0.6.0 beta2** the SLIs (Definition of Metrics & Queries) are stored as Config Map Entries. This will change for the final release as they will also be stored in the Git repo which makes it easier to change SLIs. Check out the sample_dynatrace_sli.yaml and the 5 SLIs I specified. You will notice the new Dynatrace Metrics API Query Langauge!

SLOs are already stored in Git for a specific project and stage. In our case we upload the sample_slo.yaml to our sampleservice in our sample project for the hardening stage! Check out the yaml file. You will see that I kept it simply. One SLI actually has conditions specified, the other ones are just "informational" which means the Quality Gate will pull the data but currently wont include it for the overall scoring. This has been a feature requested by many as you dont necessarily know from the start what your SLOs are for each indictor!

```
cd ../sample
kubectl apply -f sample_dynatrace_sli.yaml
~/keptn add-resource --project=sample --service=sampleservice --stage=hardening --resource=sample_slo.yaml --resourceUri=slo.yaml
```

You should see the slo.yaml file also in your own git repo that you have configured during the keptn create project step. You should see that repo having a master and a hardening branch and you will find the slo.yaml in the folder for the sampleservice. If you want to make any modifications to the slo.yaml you can now also just make it there!

# 3. Lets run these quality gates

## 3.1 Execute a Quality Gate Evaluation
Our project is ready and we can now start triggering evaluations of our SLOs. We can do this via keptn send event start-evaluation and passing it the project, service, stage and timeframe we want to be analyzed.
```
~/keptn send event start-evaluation --project=sample --service=sampleservice --stage=hardening --timeframe=5m --start=2019-11-20T11:00:00
```
This command will kick off the evaluation. Evaluations can be done in seconds but may also take a while as every SLI provider needs to query each SLIs first. This is why the keptn cli will return the keptn context which is basically a token we can use to poll the status of this particular evaluation. The output of the previous command looks like this:
```
Starting to send a start-evaluation event to evaluate the service sampleservice in project sample
ID of Keptn context: 6cd3e469-cbd3-4f73-92c3-8b2fb341bb11
```

## 3.2 Getting the Quality Gate Result
With the keptn context for our evaluation we can ask keptn about the evaluation-done which is sent by keptn's lighthouse service once all SLI providers have returned their data and keptn could evaluate all SLOs. To do this we can use - obviously you have to use your keptn-context
```
~/keptn get event evaluation-done --keptn-context=YOUR-KEPTN-CONTEXT-FROM-EVALUATION-START
```
![](images/keptn-cli-evaluation-done-result.png)

Another way to look at the data is through the keptn bridge where we also get a nice UI visualization of every SLI!
![](images/keptn-bridge-evaluation-done.png)

## 3.3 Additional Evaluation Options
Here are some additional examples for start-evaluation

**Example #1:** Evaluate the last hour by omitting start timeframe and just specifying timeframe
```
~/keptn send event start-evaluation --project=sample --service=sampleservice --stage=hardening --timeframe=1h
```

# 4. Understanding and extending SLIs with Dynatrace Calculated Service Metrics

Dynatrace's [Metrics APIv2](https://www.dynatrace.com/support/help/extend-dynatrace/dynatrace-api/environment-api/metric/selector-transformations/) provides powerful query options. Besides specifying the metric you want you can define use the scope option to filter on tags, management zones, entities, dimensions ...
When keptn executes these queries you can use a bunch of placeholders that keptn passes to the SLI services. More details can be found in the [Dynatrace SLI documentation](https://github.com/keptn-contrib/dynatrace-sli-service/tree/release-0.1.0). If you have tagged your services with project, service or stage you can use these placeholders like shown on that doc page, e.g:
```
scope=tag(keptn_project:$PROJECT),tag(keptn_stage:$STAGE),tag(keptn_service:$SERVICE),tag(keptn_deployment:canary)
```

As of **keptn 0.6.beta** the SLIs have to either be specified globally for the whole keptn Dynatrace SLI installation or you can define them per keptn project. In both cases the SLI definitions are stored as ConfigMap in k8s. This will change with the final release so SLIs can also be specified in Git which makes it much easier to modify.

## 4.1 Adding a Calculated Service Metric for Response Time & Database Activity split by URL

One of the key requirements from users on quality gates was to not just define SLOs on overall Response Time of a service but rather define different SLOs for the different URL endpoints, e.g: /api/login, /api/logout, /api/somethingelse like I can see them in the Service Details views
![](images/dnatrace-top-requests-view.png)

In order to have these values available as metrics we can leverage a new capability that is currently (as of November 2019) [available for preview](https://www.dynatrace.com/news/blog/custom-metrics-for-services-enrich-dynatrace-ai-and-dashboarding-capabilities-eap/). It allows us to have Dynatrace create new metrics based on distributed tracing (PurePath) data, e.g: Response Time split by URL, Time in Database split by URL, Response Time split by Test Name (this works well for automated testing)
While we can create these metrics through the Dynatrace UI as described in the [blog from Michael Kopp](https://www.dynatrace.com/news/blog/custom-metrics-for-services-enrich-dynatrace-ai-and-dashboarding-capabilities-eap/) we can also create these metrics through the REST API. I have prepared a script that will create 3 Metrics for us
1. Top URL Response Time (calc:service.topurlresponsetime)
2. Top URL Service Calls (calc:service.topurlservicecalls)
3. Top URL DB Calls (calc:service.topurldbcalls)

Metrics are not calculated for every distributed trace but only those that meet a certain condition, e.g: only those on a particular service. In my sample I decided to use our service tag as the condition which is why we have to call our script with the information about our tag:
```
./createCalculatedMetrics.sh CONTEXTLESS sampleservice-hardening
```

After this script runs you should see three service metric definitions in dynatrace. Go to Settings -> server-side monitoring -> Service Metrics
![](images/dynatrace-custom-service-metrics.png)

These metrics are now available for charting - in my case I can see my individual endpoints such as /api/invoke, /health, ...
![](images/dynatrace-custom-metric-chart.png)

## 4.2 Include new metrics in SLI and SLO

In order for keptn to query these new metrics we need to extend the SLI and add these metrics to the SLO. 
I have prepared a new sample_dynatrace_sli_extended.yaml file which includes queries to these three metrics - focusing on my /api/invoke endpoint. 
**ATTENTION**: If you want to use this with your service you need to edit the sli yaml and change the filter to match one of your endpoints.
![](images/sli_custom_urlendpoints.png) 

Now its time to update the SLI. As of **keptn 0.6.beta** this has to be done by updating the config map via kubectl apply:
```
kubectl apply -f sample_dynatrace_sli_extended.yaml
```

Last thing we need to do is extend the SLO to include these 3 new SLI definitions. To keep it simply I only add these SLIs without any conditions. 
Where do we change that? Just in Git as our SLOs are version controlled for our service for every stage. In our case we add the following three lines to the slo.yaml in simpleservice in the hardening branch:
```
  - sli: rt_invoke_avg
  - sli: count_svccalls_invoke
  - sli: count_dbcalls_invoke
```
Here my git update:
![](images/slo-git-update.png)

## 4.3 Lets run another quality gate evaluation

With the updated SLI and SLO in place we can run another evaluation run just as we did before!

```
~/keptn send event start-evaluation --project=sample --service=sampleservice --stage=hardening --timeframe=10m --start=2019-11-21T11:00:00
```

And then wait for the result via the CLI or just opening up the keptns Bridge:
![](sample/keptn-bridge-evaluation-done-extended.png)

# 5 Interacting with Keptn via the API

Keptn provides a REST API and a Swagger UI to easily interact with the API. What you need is the Keptn Token which you can get through this command:
```
KEPTN_API_TOKEN=$(kubectl get secret keptn-api-token -n keptn -ojsonpath={.data.keptn-api-token} | base64 --decode)
echo $KEPTN_API_TOKEN
```
If you dont remember the API endpoint then simply execute
```
~/keptn status
```

It will tell you the API Endpoint. To access the Swagger UI simply add /swagger-ui to that URL!

## 5.1 Sending Start Evaluation Events

Here is an example on how to execute a Start Evaluation Event (type=sh.keptn.event.start-evaluation). 
There are only a couple of items you need to pass in the data section:
* start: defines the start timestamp of the evaluation timeframe
* end: end timestamp of the evaluation timeframe
* project, service, stage: this is your keptn project, service and stage
* teststrategy: this one has to be "manual" right now
```
{
  "data": {
    "start": "2019-11-21T11:00:00.000Z",
    "end": "2019-11-21T11:10:00.000Z",
    "project": "sample",
    "service": "sampleservice",
    "stage": "hardening",
    "teststrategy": "manual"
  },
  "type": "sh.keptn.event.start-evaluation"
}
```

And here is the corresponding curl where you can see how send a POST to the /event endpoint. The keptn token gets passed via the x-token header!
```
curl -X POST "http://api.keptn.12.34.56.78.xip.io/v1/event" -H "accept: application/json" -H "x-token: YOUR_KEPTN_TOKEN" -H "Content-Type: application/json" -d "{ \"data\": { \"end\": \"2019-11-21T11:10:00.000Z\", \"project\": \"sample\", \"service\": \"sampleservice\", \"stage\": \"hardening\", \"start\": \"2019-11-21T11:00:00.000Z\", \"teststrategy\": \"manual\" }, \"type\": \"sh.keptn.event.start-evaluation\"}"
```

What comes back is the keptn context that was created for you, here an example
```
{"keptnContext":"384dae76-2d31-41e6-9204-39f2c1513906","token":"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE2MDU0NDA4ODl9.OdkhIoJ9KuT4bm7imvEXHdEPjnU0pl5S7DqGibNa924"}
```

## 5.2 Query for Evaluation Done

This is a simple GET request to the /event endpoint. Here is an example for the keptnContext returned in the previous example:
```
curl -X GET "http://api.keptn.12.34.56.78.xip.io/v1/event?keptnContext=384dae76-2d31-41e6-9204-39f2c1513906&type=sh.keptn.events.evaluation-done" -H "accept: application/json" -H "x-token: YOUR_KEPTN_TOKEN"
```

And here the response that comes back in my case:
```
{"contenttype":"application/json","data":{"deploymentstrategy":"","evaluationdetails":{"indicatorResults":[{"score":1,"status":"pass","targets":[{"criteria":"\u003c=+10%","targetValue":186.30640506908065,"violated":false},{"criteria":"\u003c600","targetValue":600,"violated":false}],"value":{"metric":"response_time_p95","success":true,"value":169.36945915370967}},{"score":0,"status":"info","targets":null,"value":{"metric":"throughput","success":true,"value":1}},{"score":0,"status":"info","targets":null,"value":{"metric":"error_rate","success":true,"value":0}},{"score":0,"status":"info","targets":null,"value":{"metric":"response_time_p50","success":true,"value":0.6075295178067817}},{"score":0,"status":"info","targets":null,"value":{"metric":"response_time_p90","success":true,"value":168.3322319758899}},{"score":0,"status":"info","targets":null,"value":{"message":"Dynatrace API returned status code 404 - Metric could not be received.","metric":"rt_invoke_avg","success":false,"value":0}},{"score":0,"status":"info","targets":null,"value":{"message":"Dynatrace API returned status code 404 - Metric could not be received.","metric":"count_svccalls_invoke","success":false,"value":0}},{"score":0,"status":"info","targets":null,"value":{"message":"Dynatrace API returned status code 404 - Metric could not be received.","metric":"count_dbcalls_invoke","success":false,"value":0}}],"result":"pass","score":100,"sloFileContent":"Y29tcGFyaXNvbjoKICBhZ2dyZWdhdGVfZnVuY3Rpb246IGF2ZwogIGNvbXBhcmVfd2l0aDogc2luZ2xlX3Jlc3VsdAogIGluY2x1ZGVfcmVzdWx0X3dpdGhfc2NvcmU6IHBhc3MKICBudW1iZXJfb2ZfY29tcGFyaXNvbl9yZXN1bHRzOiAzCmZpbHRlcjogbnVsbApvYmplY3RpdmVzOgotIGtleV9zbGk6IGZhbHNlCiAgcGFzczoKICAtIGNyaXRlcmlhOgogICAgLSA8PSsxMCUKICAgIC0gPDYwMAogIHNsaTogcmVzcG9uc2VfdGltZV9wOTUKICB3YXJuaW5nOgogIC0gY3JpdGVyaWE6CiAgICAtIDw9ODAwCiAgd2VpZ2h0OiAxCi0ga2V5X3NsaTogZmFsc2UKICBwYXNzOiBudWxsCiAgc2xpOiB0aHJvdWdocHV0CiAgd2FybmluZzogbnVsbAogIHdlaWdodDogMQotIGtleV9zbGk6IGZhbHNlCiAgcGFzczogbnVsbAogIHNsaTogZXJyb3JfcmF0ZQogIHdhcm5pbmc6IG51bGwKICB3ZWlnaHQ6IDEKLSBrZXlfc2xpOiBmYWxzZQogIHBhc3M6IG51bGwKICBzbGk6IHJlc3BvbnNlX3RpbWVfcDUwCiAgd2FybmluZzogbnVsbAogIHdlaWdodDogMQotIGtleV9zbGk6IGZhbHNlCiAgcGFzczogbnVsbAogIHNsaTogcmVzcG9uc2VfdGltZV9wOTAKICB3YXJuaW5nOiBudWxsCiAgd2VpZ2h0OiAxCi0ga2V5X3NsaTogZmFsc2UKICBwYXNzOiBudWxsCiAgc2xpOiBydF9pbnZva2VfYXZnCiAgd2FybmluZzogbnVsbAogIHdlaWdodDogMQotIGtleV9zbGk6IGZhbHNlCiAgcGFzczogbnVsbAogIHNsaTogY291bnRfc3ZjY2FsbHNfaW52b2tlCiAgd2FybmluZzogbnVsbAogIHdlaWdodDogMQotIGtleV9zbGk6IGZhbHNlCiAgcGFzczogbnVsbAogIHNsaTogY291bnRfZGJjYWxsc19pbnZva2UKICB3YXJuaW5nOiBudWxsCiAgd2VpZ2h0OiAxCnNwZWNfdmVyc2lvbjogMC4xLjAKdG90YWxfc2NvcmU6CiAgcGFzczogOTAlCiAgd2FybmluZzogNzUlCg==","timeEnd":"2019-11-21T11:10:00.000Z","timeStart":"2019-11-21T11:00:00.000Z"},"project":"sample","result":"pass","service":"sampleservice","stage":"hardening","teststrategy":"manual"},"id":"c6ef3d94-a528-4f3d-85bd-5fe1183dd2c9","source":"lighthouse-service","specversion":"0.2","time":"2019-11-21T11:48:11.130Z","type":"sh.keptn.events.evaluation-done","shkeptncontext":"384dae76-2d31-41e6-9204-39f2c1513906"}
```
