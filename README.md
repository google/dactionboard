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
* Access to repository configured. In order to clone this repository you need to do the following:
    * Visit https://professional-services.googlesource.com/new-password and login with your account
    * Once authenticated please copy all lines in box and paste them in the terminal.
* (*Optional*) If running application outside of Google Cloud console please generate [service account](https://cloud.google.com/iam/docs/creating-managing-service-accounts#creating) and download [service account key](https://cloud.google.com/iam/docs/creating-managing-service-account-keys#creating) in order to write data to BigQuery.
    * Once you downloaded service account key export it as an environmental variable
        ```
        export GOOGLE_APPLICATION_CREDENTIALS=path/to/service_account.json
        ```

### Installation
In order to run dActionBoard please follow the steps outlined below:

* clone this repository
    ```
    git clone https://professional-services.googlesource.com/solutions/dactionboard
    ```
* (Recommended) configure virtual environment if you starting testing the solution:
    ```
    python -m venv dactionboard
    source dactionboard/bin/activate
    ```
* install dependencies:
    ```
    pip install -r requirements.txt
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

##### Running queries locally

###### Run with individual parameters
*Back to [usage](#usage)*

Running queries with CLI arguments is **generally discouraged** but might be useful if you want to re-run a particular query or a set of queries with a new parameter before adding it to config.

1. Specify environmental variables

```
export GOOGLE_APPLICATION_CREDENTIALS=path/to/service_account.json
export DACTIONBOARD_CUSTOMER_ID=
export DACTIONBOARD_BQ_PROJECT=
export DACTIONBOARD_BQ_DATASET=
export DACTIONBOARD_OUTPUT_DATASET=
export DACTIONBOARD_START_DATE=
export DACTIONBOARD_END_DATE=
```

* `GOOGLE_APPLICATION_CREDENTIALS` - check Service Account Section in [prerequisites](#prerequisites).
* `DACTIONBOARD_CUSTOMER_ID` should be specified in `1234567890` format (no dashes between digits).
* `DACTIONBOARD_START_DATE` and `DACTIONBOARD_END_DATE` should be specified in `YYYY-MM-DD` format (i.e. 2022-01-01) or as `:YYYYMMDD-N` macro (where N is a number of days ago, i.e., :YYYYMMDD-7 means 7 days ago).

2. Run `gaarf` command to fetch Google Ads data and store them in BigQuery

```
gaarf google_ads_queries/*/*.sql \
    --account=$DACTIONBOARD_CUSTOMER_ID \
    --output=bq \
    --bq.project=$DACTIONBOARD_BQ_PROJECT \
    --bq.dataset=$DACTIONBOARD_BQ_DATASET \
    --macro.start_date=$DACTIONBOARD_START_DATE \
    --macro.end_date=$DACTIONBOARD_END_DATE \
    --ads-config=path/to/google-ads.yaml
```

You can replace `google_ads_queries/*/*.sql` with a path to a particular query or queries, i.e.

* `google_ads_queries/settings/*.sql` will run all queries from `google_ads_queries/settings/` folder.
* `google_ads_queries/performance/ad_performance.sql` will run only `ad_performance.sql` query.

3. Run `gaarf-bq` command to prepare tables in BigQuery based on data
fetched by `gaarf` command.

```
gaarf-bq bq_queries/*.sql \
    --project=$DACTIONBOARD_BQ_PROJECT \
    --macro.bq_dataset=$DACTIONBOARD_BQ_DATASET \
    --macro.output_dataset=$DACTIONBOARD_OUTPUT_DATASET
```

As in the step 2 you can run a single query from `bq_folder` if needed.

###### Run with config
*Back to [usage](#usage)*

The repository contains `config.yaml.template` file where we can specify all parameters.
Make a copy of this template (rename to something like `dactionboard.yaml`) and replace placeholders inside new file.

Alternatively you can use `dactionboard.yaml` config file generated when [running an interactive installer](#initial-setup-and-run-via-an-interactive-installer).

Once config file is up-to-date you can run the following command in your terminal:

```
gaarf google_ads_queries/*/*.sql -c=dactionboard.yaml \
    --ads-config=path/to/google-ads.yaml
gaarf-bq bq_queries/*.sql -c=dactionboard.yaml
```

#### Run queries in a Docker container
*Back to [usage](#usage)*

You can run dActionBoard queries inside a Docker container.

1. Build `dactionboard` image:

```
sudo docker build . -t dactionboard
```

It will create `dactionboard` docker image you can use later on. It expects the following inputs:
* `google-ads.yaml` - absolute path to `google-ads.yaml` file
* `service_account.json` - absolute path to service account json file
* `dactionboard.yaml` - absolute path to YAML config

2. Run:

```
sudo docker run \
    -v /path/to/google-ads.yaml:/google-ads.yaml \
    -v /path/to/service_account.json:/service_account.json \
    -v /path/to/dactionboard.yaml:/config.yaml \
    dactionboard
```

> Don't forget to change /path/to/google-ads.yaml and /path/to/service_account.json with valid paths.

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
