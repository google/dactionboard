#!/bin/bash
ads_queries=$1
bq_queries=$2
gaarf $ads_queries -c=config.yaml --ads-config=google-ads.yaml
gaarf-bq $bq_queries -c=config.yaml
