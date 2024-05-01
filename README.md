# ElasticSearch Database Backup and Cloud Storage Upload

Introduction:

We were tasked with backing up an ElasticSearch database and sending it to a cloud storage bucket. To achieve this, we utilized ElasticDump to export the database indices and mappings, and then uploaded them to Google Cloud Storage (GCS).

Pre-requisites:

1- Ensure ElasticDump is installed. Install it via npm:

  sudo npm install elasticdump -g

  Obtain the ElasticSearch credentials (username and password) and the GCS bucket details.

2- Script:

For script refer script.sh and PDF document.


3- Testing:

We tested this script in our test environment by first port forwarding the cluster's

ElasticSearch service:

  kubectl port-forward service/service-name oursetport:9200

Then, we set the ElasticSearch username and password and used localhost:9200 as the host and port in the script. We triggered the script, which successfully retrieved the indices data and mappings and sent them to the GCS bucket.Kubernetes CronJob Deployment

4- To automate the backup process, we deployed the script as a Kubernetes CronJob. 

5- For image refer to Dockerfile and Yaml file for kubernetes cronjob configuration.

6- Service Account if your kubernetes pod want to communicate with gcp services. For this you need service account. You need to bind service account of kubernetes and gcp with “WORKLOAD IDENTITY” steps are given in document:


