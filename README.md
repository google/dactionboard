# dActionBoard - Video Action Campaigns Reporting

## Problem statement

Crucial information on Video Action campaigns - especially related to video-level
performance and creative excellence - is scattered across various places in
Google Ads UI which make it harder to get insights into how campaigns and
video perform.

## Solution

dActionBoard is Data Studio based dashboard that provides a comprehensive overview of your Video Action campaigns.

Key pillars of dActionBoard:

* High level overview of Video Action campaigns performance
* Deep dive analysis (by age, gender, geo, devices, etc.)
* Overview of creative excellence and ways of improving campaign performance based on Google recommendations
* Video level analytics

## Deliverable

A set of tables in BigQuery that are used for generating DataStudio dashboard.

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

## Deployment
### Prerequisites

* Google Ads API access and [google-ads.yaml](https://github.com/google/ads-api-report-fetcher/blob/main/docs/how-to-authenticate-ads-api.md#setting-up-using-google-adsyaml) file - follow documentation on [API authentication](https://github.com/google/ads-api-report-fetcher/blob/main/docs/how-to-authenticate-ads-api.md).
* Python 3.8+
* (*Optional*) If running application outside of Google Cloud console please generate [service account](https://cloud.google.com/iam/docs/creating-managing-service-accounts#creating) and download [service account key](https://cloud.google.com/iam/docs/creating-managing-service-account-keys#creating) in order to write data to BigQuery.
    * Once you downloaded service account key export it as an environmental variable
        ```
        export GOOGLE_APPLICATION_CREDENTIALS=path/to/service_account.json
        ```

### Installation
In order to run dActionBoard please follow the steps outlined below:

* clone this repository
    ```
    git clone https://github.com/google/dactionboard
    ```
* (Recommended) configure virtual environment if you starting testing the solution:
    ```
    python -m venv dactionboard
    source dactionboard/bin/activate
    ```
* install dependencies:
    ```
    pip install --require-hashes -r requirements.txt
    ```

### Usage

1. [Generate tables](#generate-tables)
    1. [Option 1: Initial setup and run via an interactive installer](#initial-setup-and-run-via-an-interactive-installer)
    2. [Option 2: Running queries locally](#running-queries-locally)
        * [With individual parameters](#run-with-individual-parameters)
        * [With config](#run-with-config)
    3. [Option 3: Running queries in a Docker container](#run-queries-in-a-docker-container)
2. [Create dashboard](#create-dashboard)


#### Generate tables

##### Initial setup and run via an interactive installer

If you setup dActionBoard it's highly recommended to run an interactive installer.
Please run the following command in your terminal:

```
bash run-local.sh
```

It will guide you through a series of questions to get all necessary parameters to run the scripts:

* `account_id` - id of Google Ads MCC account (no dashes, 111111111 format)
* `BigQuery project_id` - id of BigQuery project where script will store the data (i.e. `my_project`)
* `BigQuery dataset` - id of BigQuery dataset where script will store the data (i.e. `my_dataset`)
* `start date` - first date from which you want to get performance data (i.e., `2022-01-01`)
* `end date` - last date from which you want to get performance data (i.e., `2022-12-31`)
* `Ads config` - path to `google-ads.yaml` file.

After the initial run of `run-local.sh` command it will generate `dactionboard.yaml` config file with all necessary information used for future runs.\
When you run `bash run-local.sh` next time it will automatically pick up created configuration.
This configuration file can also be used when [running queries with config](#run-with-config) or [running queries in a Docker container](#run-queries-in-a-docker-container).

#### Run queries in a Docker container
*Back to [usage](#usage)*

You can run dActionBoard queries inside a Docker container.

```
sudo docker run \
   -v /path/to/google-ads.yaml.json:/google-ads.yaml \
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

#### Create dashboard
*Back to [usage](#usage)*

In order to generate the dashboard run the following command in the terminal:

```
bash scripts/create_dashboard.sh dactionboard.yaml
```

This command will open a link in your browser with a copy of the dashboard.
Alternatively you can follow the documentation on dashboard replication at [how-to-replicate-dashboard](docs/how-to-replicate-dashboard.md) section in docs.

## Disclaimer
This is not an officially supported Google product.
