# dActionBoard - Video Action Campaigns Reporting & Alerts

dActionBoard is Data Studio based dashboard that provides a comprehensive overview of your Video Action campaigns.

Key pillars of dActionBoard:

* High level overview of Video Action campaigns performance
* Deep dive analysis (by age, gender, geo, devices, etc.)
* Overview of creative excellence and ways of improving campaign performance based on Google recommendations
* Video level analytics


## Prerequisites

* [Python 3](https://www.python.org/downloads/) and [pip](https://pip.pypa.io/en/stable/installation/) installed.

## Getting started
* Create virtual environment `python -m venv dactionboard` and activate it with `source dactionboard/bin/activate`.
* Install `google-ads-api-report-fetcher` library with `pip install google-ads-api-report-fetcher`.
* Follow documentation on [API authentication](https://github.com/google/ads-api-reports-fetcher#getting-started) to generate `google-ads.yaml` file;
    if you already have such file you may skip this step.


## Running queries locally

### Run with individual parameters

1. Specify enviromental variables

```
export GOOGLE_APPLICATION_CREDENTIALS=path/to/service_account.json
export CUSTOMER_ID=
export BQ_PROJECT=
export BQ_DATASET=
export START_DATE=
export END_DATE=
```

* `GOOGLE_APPLICATION_CREDENTIALS` - path to json file containing [service account key](https://cloud.google.com/docs/authentication/getting-started).
* `CUSTOMER_ID` should be specifed in `1234567890` format (no dashes between digits).
* `START_DATE` and `END_DATE` should be specified in `YYYY-MM-DD` format (i.e. 2022-01-01) or as `:YYYYMMDD-N` macro (where N is a number of days ago, i.e., :YYYYMMDD-7 means 7 days ago).

2. Run `gaarf` command to fetch Google Ads data and store them in BigQuery

```
gaarf google_ads_queries/*/*.sql \
    --account=$CUSTOMER_ID \
    --output=bq \
    --bq.project=$BQ_PROJECT \
    --bq.dataset=$BQ_DATASET \
    --macro.start_date=$START_DATE \
    --macro.end_date=$END_DATE \
    --ads-config=path/to/google-ads.yaml
```

3. Run `gaarf-bq` command to prepare tables in BigQuery based on data
fetched by `gaarf` command.

```
gaarf-bq bq_queries/*.sql \
    --macro.bq_project=$BQ_PROJECT \
    --macro.bq_dataset=$BQ_DATASET
```

### Run with config

The repository contains `config.yaml.template` file where we can specify all parameters.
Make a copy of this template (rename to something like `dactionboard-config.yaml`), replace placeholders inside new file and use on command line like that:

```
gaarf google_ads_queries/*/*.sql -c=dactionboard-config.yaml \
    --ads-config=path/to/google-ads.yaml
gaarf-bq bq_queries/*.sql -c=dactionboard-config.yaml
```

## Run queries in a Docker container

You can run dActionBoard queries inside a Docker container.

1. Build `dactionboard` image:

```
sudo docker build . -t dactionboard
```

It will create `dactionboard` docker image you can use later on. It expectes the following inputs:
    * `google-ads.yaml` - absolute path to `google-ads.yaml` file
    * `service_account.json` - absolute path to service account json file
    * `config.yaml` - absolute path to YAML config

2. Run:

```
sudo docker run \
    -v /path/to/google-ads.yaml:/google-ads.yaml \
    -v /path/to/service_account.json:/service_account.json \
    -v /path/to/gaarf_config.yaml:/config.yaml \
    dactionboard
```

> Don't forget to change /path/to/google-ads.yaml and /path/to/service_account.json with valid paths.

## Disclaimer
This is not an officially supported Google product.

Copyright 2022 Google LLC. This solution, including any related sample code or data, is made available on an “as is,” “as available,” and “with all faults” basis, solely for illustrative purposes, and without warranty or representation of any kind. This solution is experimental, unsupported and provided solely for your convenience. Your use of it is subject to your agreements with Google, as applicable, and may constitute a beta feature as defined under those agreements. To the extent that you make any data available to Google in connection with your use of the solution, you represent and warrant that you have all necessary and appropriate rights, consents and permissions to permit Google to use and process that data. By using any portion of this solution, you acknowledge, assume and accept all risks, known and unknown, associated with its usage, including with respect to your deployment of any portion of this solution in your systems, or usage in connection with your business, if at all.

