# dActionBoard - Video Action Campaigns Reporting

## Table of Content
1. [Introduction](#introduction)
1. [Deliverables](#deliverables)
1. [Prerequisites](#prerequisites)
1. [Installation](#installation)
    * [Primary Installation Method](#primary-installation-method)
    * [Manual installation in Google Cloud](#manual-installation-in-google-cloud)
    * [Gaarf Workflow Installation in Google Cloud](#gaarf-workflow-installation-in-google-cloud)
    * [Alternative Installation Methods](#alternative-installation-methods)
        * [Prerequisites for alternative installation methods](#prerequisites-for-alternative-installation-methods)
        * [Running Queries Locally](#running-queries-locally)
        * [Running in a Docker Container](#running-in-a-docker-container)
        * [Running in Apache Airflow](#running-in-apache-airflow)
1. [Dashboard Replication](#dashboard-replication)
1. [Disclaimer](#disclaimer)


## Introduction

Crucial information on Video Action campaigns - especially related to video-level
performance and creative excellence - is scattered across various places in
Google Ads UI which make it harder to get insights into how campaigns and
video perform.

dActionBoard is Data Studio based dashboard that provides a comprehensive overview of your Video Action campaigns.

Key pillars of dActionBoard:

* High level overview of Video Action campaigns performance
* Deep dive analysis (by age, gender, geo, devices, etc.)
* Overview of creative excellence and ways of improving campaign performance based on Google recommendations
* Video level analytics

## Deliverables

1. A centralized dashboard with deep video campaign and assets performance views
2. The following data tables in BigQuery that can be used independently:

List of tables:
* `ad_video_performance`
* `age_performance`
* `conversion_split`
* `creative_excellence`
* `device_performance`
* `gender_performance`
* `geo_performance`
* `video_conversion_split`
* `video_performance`

## Prerequisites
*Back to [table of content](#table-of-content)*

1. [A Google Ads Developer token](https://developers.google.com/google-ads/api/docs/first-call/dev-token#:~:text=A%20developer%20token%20from%20Google,SETTINGS%20%3E%20SETUP%20%3E%20API%20Center.)

1. A new GCP project with billing account attached

1. Membership in [dactionboard-readers-external](https://groups.google.com/g/dactionboard) group to get access to the template dashboard and datasources. You can apply [here](https://groups.google.com/g/dactionboard).

1. Credentials for Google Ads API access - `google-ads.yaml`.
   See details here - https://github.com/google/ads-api-report-fetcher/blob/main/docs/how-to-authenticate-ads-api.md
   Normally you need OAuth2 credentials (Client ID, Client Secret), a Google Ads developer token and a refresh token.

## Installation
There are several ways to run the application. A recommended way is to run it
in the Google Cloud but it's not a requirement. You can run dActionBoard locally or
in your own infrastructure. In either way you need two things:
* Google Ads API credentials (in `google-ads.yaml` or separately)
* dActionBoard configuration (in `dactionboard.yaml`) - it can be generated via running `run-local.sh`.
In order to run dActionBoard please follow the steps outlined below:

### Primary Installation Method
*Back to [table of content](#table-of-content)*

The primary installation method deploys dActionBoard into Google Cloud by using Cloud Run Button.
The procedure automates generating dActionBoard configuration and deploying all required components to the Cloud.

This approach is the simplest one because it clones the repo and starts install scripts for you. But sometimes you might need some customization.
The majority infrastructure settings can be changed in `gcp/settings.ini` file (regions, service names, etc).
If it's a case for you please use the [Manual installation in Google Cloud](#manual-installation-in-google-cloud) below.

To install the solution, follow these steps:

1. Click "Run on Google Cloud"
   [![Run on Google Cloud](https://deploy.cloud.run/button.svg)](https://deploy.cloud.run?dir=gcp/cloud-run-button)

1. Select your GCP project and choose any region.

1. When prompted, upload your `google-ads.yaml` (alternately you can paste in your client ID, client secret, refresh token, developer token and MCC ID later).

1. The install script will generate dActionBoard configuration by asking some interactive questions and then deploy all cloud components in the current project

1. At the end you will be given a link to a webpage on Cloud Storage where you can track the progress.

1. This webpage will inform you once the BigQuery datasets have been populated and you can create a dashboard.
When the button is enabled, click "Open Dashboard" to clone the dashboard template.
Click the "Save" button on the top right to save your new dashboard.

1. Change your dashboard's name and save it's URL or bookmark it.

It's important to note that a Cloud Run service that is being built and deployed during installation isn't actually needed (it'll be removed at the end).
All dActionBoard installation happens in a pre-build script.


### Manual installation in Google Cloud
*Back to [table of content](#table-of-content)*

1. First you need to clone the repo in Cloud Shell or on your local machine (we assume Linux with gcloud CLI installed):
```
git clone https://github.com/google/dactionboad
```

1. Go to the repo folder: `cd dactionboard`

1. Optionally put your `google-ads.yaml` there or be ready to provide all Ads API credentials

1. Optionally adjust settings in `settings.ini`

1. Run installation:
```
./gcp/install.sh
```

If you already have dActionBoard configuration (`dactionboard.yaml`) then you can directly deploy all components via running:
```
./gcp/setup.sh deploy_public_index deploy_all start
```

>TIP: when you install via clicking Cloud Run Button basically you run the same install.sh but in an automatically created Shell.


The setup script with 'deploy_all' target does the followings:
* enable APIs
* grant required IAM permissions
* create a repository in Artifact Repository
* build a Docker image (using `gcp/workload-vm/Dockerfile` file)
* publish the image into the repository
* deploy Cloud Function `create-vm` (from gcp/cloud-functions/create-vm/) (using environment variables in env.yaml file)
* deploy configs to GCS (config.yaml and google-ads.yaml) (to a bucket with a name of current GCP project id and 'dactionboard' subfolder)
* create a Scheduler job for publishing a pubsub message with arguments for the CF

The setup script with 'deploy_public_index' uploads the index.html webpage on a GCS public bucket,
the page that you can use to track installation progress, and create a dashboard at the end.

What happens when a pubsub message published (as a result of `setup.sh start`):
* the Cloud Function 'create-vm' get a message with arguments and create a virtual machine based a Docker container from the Docker image built during the installation
* the VM on startup parses the arguments from the CF (via VM's attributes) and execute dActionBoard in quite the same way as it executes locally (using `run-local.sh`).
Additionally the VM's entrypoint script deletes the virtual machine upon completion of the run-local.sh.

### Troubleshooting
If you're getting an error at the creating Docker repository step:
```
ERROR: (gcloud.artifacts.repositories.create) INVALID_ARGUMENT: Maven config is not supported for format "DOCKER"
- '@type': type.googleapis.com/google.rpc.DebugInfo
  detail: '[ORIGINAL ERROR] generic::invalid_argument: Maven config is not supported
    for format "DOCKER" [google.rpc.error_details_ext] { code: 3 message: "Maven config
    is not supported for format \"DOCKER\"" }'
```
Please update your Cloud SDK CLI by running `gcloud components update`


### Gaarf Workflow Installation in Google Cloud
*Back to [table of content](#table-of-content)*

You can use [Gaarf Workflows](https://github.com/google/ads-api-report-fetcher/tree/main/gcp) to deploy dactionBoard.

1. Clone this repository and go to dactionboard folder `cd dactionboard`
2. Start the interactive generation `npm init gaarf-wf@latest -- --answers=answers.json`
> You need Node.js and npm installed to complete the previous step.
3. Follow steps outlined in the interactive tool.
4. Once the installation is completed you'll get a link for replicating the dashboard.

### Alternative Installation Methods
*Back to [table of content](#table-of-content)*

#### Prerequisites for alternative installation methods

* Google Ads API access and [google-ads.yaml](https://github.com/google/ads-api-report-fetcher/blob/main/docs/how-to-authenticate-ads-api.md#setting-up-using-google-adsyaml) file - follow documentation on [API authentication](https://github.com/google/ads-api-report-fetcher/blob/main/docs/how-to-authenticate-ads-api.md).
* Python 3.8+
* [Service account](https://cloud.google.com/iam/docs/creating-managing-service-accounts#creating) created and [service account key](https://cloud.google.com/iam/docs/creating-managing-service-account-keys#creating) downloaded in order to write data to BigQuery.
    * Once you downloaded service account key export it as an environmental variable
        ```
        export GOOGLE_APPLICATION_CREDENTIALS=path/to/service_account.json
        ```

    * If authenticating via service account is not possible you can authenticate with the following command:
         ```
         gcloud auth application-default login
         ```

#### Running queries locally
*Back to [table of content](#table-of-content)*

In order to run App Reporting Pack locally please follow the steps outlined below:

* clone this repository
    ```
    git clone https://github.com/google/dactionboard
    cd dactionboard
    ```
* (Recommended) configure virtual environment if you starting testing the solution:
    ```
    sudo apt-get install python3-venv
    python3 -m venv dactionboard
    source dactionboard/bin/activate
    ```
* Make sure that that pip is updated to the latest version:
    ```
    python3 -m pip install --upgrade pip
    ```
* install dependencies:
    ```
    pip install --require-hashes -r requirements.txt --no-deps
    ```
Please run `run-local.sh` script in a terminal to generate all necessary tables for App Reporting Pack:

```shell
bash ./run-local.sh
```

It will guide you through a series of questions to get all necessary parameters to run the scripts:

* `account_id` - id of Google Ads MCC account (no dashes, 111111111 format)
* `BigQuery project_id` - id of BigQuery project where script will store the data (i.e. `my_project`)
* `BigQuery dataset` - id of BigQuery dataset where script will store the data (i.e. `my_dataset`)
* `start date` - first date from which you want to get performance data (i.e., `2022-01-01`). Relative dates are supported [see more](https://github.com/google/ads-api-report-fetcher#dynamic-dates).
* `end date` - last date from which you want to get performance data (i.e., `2022-12-31`). Relative dates are supported [see more](https://github.com/google/ads-api-report-fetcher#dynamic-dates).
* `Ads config` - path to `google-ads.yaml` file.

After the initial run of `run-local.sh` command it will generate `dactionboard.yaml` config file with all necessary information used for future runs.
When you run `bash run-local.sh` next time it will automatically pick up created configuration.

##### Schedule running `run-local.sh` as a cronjob

When running `run-local.sh` scripts you can specify two options which are useful when running queries periodically (i.e. as a cron job):

* `-c <config>`- path to `dactionboard.yaml` config file. Comes handy when you have multiple config files or the configuration is located outside of current folder.
* `-q` - skips all confirmation prompts and starts running scripts based on config file.

If you installed all requirements in a virtual environment you can use the trick below to run the proper cronjob:

```
* 1 * * * /usr/bin/env bash -c "source /path/to/your/venv/bin/activate && bash /path/to/dactionboard/run-local.sh -c /path/to/dactionboard.yaml -g /path/to/google-ads.yaml -q"
```

This command will execute dActionBoard queries every day at 1 AM.

#### Running in a Docker Container
*Back to [table of content](#table-of-content)*

You can run dActionBoard queries inside a Docker container.

```
sudo docker run \
   -v /path/to/google-ads.yaml:/google-ads.yaml \
   -v /path/to/dactionboard.yaml:/config.yaml \
   -v /path/to/service_account.json:/service_account.json \
   ghcr.io/google/dactionboard

```
where:
* `/path/to/google-ads.yaml` - absolute path to `google-ads.yaml` file (can be remote)
* `service_account.json` - absolute path to service account json file
* `/path/to/dactionboard.yaml` - absolute path to YAML config

> Don't forget to change /path/to/google-ads.yaml and /path/to/service_account.json with valid paths.

You can provide configs as remote (for example Google Cloud Storage):

```
sudo docker run  \
  -e GOOGLE_CLOUD_PROJECT="project_name" \
  -v /path/to/service_account.json:/service_account.json \
  ghcr.io/google/dactionboard \
  gs://project_name/google-ads.yaml \
  gs://project_name/dactionboard.yaml
```
#### Running in Apache Airflow
*Back to [table of content](#table-of-content)*

Please refer to [documentation](docs/running-dactionboard-in-apache-airflow.md)
on running dActionBoard in Apache Airflow.

#### Dashboard Replication
*Back to [table of content](#table-of-content)*

In order to generate the dashboard install [Looker Studio Dashboard Cloner](https://github.com/google/looker-studio-dashboard-cloner)
and run the following command in the terminal:

```
lsd-cloner --answers=dashboard_answers.json
```

This command will open a link in your browser with a copy of the dashboard.
Alternatively you can follow the documentation on dashboard replication at [how-to-replicate-dashboard](docs/how-to-replicate-dashboard.md) section in docs.

## Disclaimer
This is not an officially supported Google product.
