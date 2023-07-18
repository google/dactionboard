#!/bin/bash
#
# Copyright 2022 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

. ./scripts/shell_utils/gaarf.sh
. ./scripts/shell_utils/functions.sh

COLOR='\033[0;36m' # Cyan
NC='\033[0m' # No color
usage="bash run-local.sh -c|--config <config> -q|--quiet\n\n
Helper script for running dActionBoard queries.\n\n
-h|--help - show this help message\n
-c|--config <config> - path to config.yaml file, i.e., path/to/dactionboard.yaml\n
-q|--quiet - skips all confirmation prompts and starts running scripts based on config files\n
-g|--google-ads-config - path to google-ads.yaml file (by default it expects it in $HOME directory)\n
-l|--loglevel - loglevel (DEBUG, INFO, WARNING, ERROR), INFO by default.
"

solution_name="dActionBoard"
solution_name_lowercase=$(echo $solution_name | tr '[:upper:]' '[:lower:]' |\
	tr ' ' '_')

config_file="$solution_name_lowercase.yaml"
quiet="n"

while :; do
case $1 in
  -q|--quiet)
    quiet="y"
    ;;
  -c|--config)
    shift
    config_file=$1
    ;;
  -l|--loglevel)
    shift
    loglevel=$1
    ;;
  -g|--google-ads-config)
    shift
    ads_config=$1
    ;;
  --generate-config-only)
    generate_config_only="y"
    ;;
  -h|--help)
    echo -e $usage;
    exit
    ;;
  *)
    break
  esac
  shift
done

# Specify customer ids query that fetch data only from accounts that have at least one app campaign in them.
customer_ids_query='SELECT customer.id FROM ad_group WHERE ad_group.type IN ("VIDEO_RESPONSIVE", "VIDEO_TRUE_VIEW_IN_DISPLAY", "VIDEO_TRUE_VIEW_IN_STREAM") AND campaign.bidding_strategy_type IN ("MAXIMIZE_CONVERSIONS", "TARGET_CPA")'

API_VERSION=13

welcome() {
  echo -e "${COLOR}Welcome to installation of $solution_name${NC} "
  echo
  echo "Please answer a couple of questions. The default answers are specified in parentheses, press Enter to select them"
  echo
}

generate_bq_macros() {
  bq_dataset_output=$(echo $bq_dataset"_output")
  macros="--macro.bq_dataset=$bq_dataset --macro.output_dataset=$bq_dataset_output"
}

setup() {
  # get default value from google-ads.yaml
  if [[ -n $ads_config ]]; then
    parse_yaml $ads_config "GOOGLE_ADS_"
    local login_customer_id=$GOOGLE_ADS_login_customer_id
  fi
  echo -n "Enter account_id in XXXXXXXXXX format ($login_customer_id): "
  read -r customer_id
  customer_id=${customer_id:-$login_customer_id}

  default_project=${GOOGLE_CLOUD_PROJECT:-$(gcloud config get-value project 2>/dev/null)}
  echo -n "Enter BigQuery project_id ($default_project): "
  read -r project
  project=${project:-$default_project}

  echo -n "Enter BigQuery dataset (dactionboard): "
  read -r bq_dataset
  bq_dataset=${bq_dataset:-dactionboard}
  get_start_end_date

  generate_bq_macros

  if [[ -n $RUNNING_IN_GCE && $generate_config_only ]]; then
    # if you're running inside Google Cloud Compute Engine as generating config
    # (see gcp/cloud-run-button/main.sh) then there's no need for additional questions
    save_config="--save-config --config-destination=$solution_name_lowercase.yaml"
    echo -e "${COLOR}Saving configuration to $solution_name_lowercase.yaml${NC}"
    fetch_reports $save_config --log=$loglevel --api-version=$API_VERSION --dry-run
    generate_output_tables $save_config --log=$loglevel --dry-run
    exit
  fi

  echo -n "Do you want to save this config (Y/n): "
  read -r save_config_answer
  save_config_answer=$(convert_answer $save_config_answer 'Y')
  if [[ $save_config_answer = "y" ]]; then
    echo -n "Save config as ($solution_name_lowercase.yaml): "
    read -r config_file_name
    config_file_name=${config_file_name:-$solution_name_lowercase.yaml}
    config_file=$(echo "`echo $config_file_name | sed 's/\.yaml//'`.yaml")
    save_config="--save-config --config-destination=$config_file"
    echo -e "${COLOR}Saving configuration to $config_file${NC}"
    fetch_reports $save_config --log=$loglevel --api-version=$API_VERSION --dry-run
    generate_output_tables $save_config --log=$loglevel --dry-run

    if [[ $generate_config_only = "y" ]]; then
      exit
    fi
  elif [[ $save_config_answer = "q" ]]; then
    exit
  fi
  print_configuration
}

print_configuration() {
  echo "Your configuration:"
  echo "  account_id: $customer_id"
  echo "  BigQuery project_id: $project"
  echo "  BigQuery dataset:: $bq_dataset"
  echo "  Start date: $start_date"
  echo "  End date: $end_date"
  echo "  Ads config: $ads_config"
}

run_with_config() {
  echo -e "${COLOR}Running with $config_file${NC}"
  if [[ -f "$config_file" ]]; then
    cat $config_file
  fi
  echo -e "${COLOR}===fetching reports===${NC}"
  gaarf $(dirname $0)/google_ads_queries/**/*.sql -c=$config_file \
    --ads-config=$ads_config --log=$loglevel --api-version=$API_VERSION
  echo -e "${COLOR}===generating final tables===${NC}"
  gaarf-bq $(dirname $0)/bq_queries/*.sql -c=$config_file --log=$loglevel
}

run_with_parameters() {
  echo -e "${COLOR}===fetching reports===${NC}"
  fetch_reports $save_config --log=$loglevel --api-version=$API_VERSION
  echo -e "${COLOR}===generating final tables===${NC}"
  generate_output_tables $save_config --log=$loglevel
}

check_ads_config

if [[ -z ${loglevel} ]]; then
  loglevel="INFO"
fi

if [[ -n "$config_file" || -f $solution_name_lowercase.yaml ]]; then
  config_file=${config_file:-$solution_name_lowercase.yaml}
  if [[ $quiet = "y" ]]; then
    run_with_config
  else
    echo -e "${COLOR}Found saved configuration at $config_file${NC}"
    echo -e "${COLOR}If you want to provide alternative configuration use '-c path/to/config.yaml' and restart.${NC}"
    if [[ -f "$config_file" ]]; then
      cat $config_file
    fi
    echo -n -e "${COLOR}Do you want to use this configuration? (Y/n) or press Q to quit: ${NC}"
    read -r setup_config_answer
    setup_config_answer=$(convert_answer $setup_config_answer 'Y')
    if [[ $setup_config_answer = "y" ]]; then
      echo -e "${COLOR}Using saved configuration...${NC}"
      run_with_config
    elif [[ $setup_config_answer = "n" ]]; then
      echo -e "${COLOR}Setting up new configuration... (Press Ctrl + C to exit)${NC}"
        setup
        prompt_running
        run_with_parameters
      else
        echo "Unknown command, exiting"
        exit
      fi
  fi
fi
