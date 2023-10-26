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
SCRIPT_PATH=$(readlink -f "$0" | xargs dirname)

source $SCRIPT_PATH/scripts/shell_utils/gaarf.sh
source $SCRIPT_PATH/scripts/shell_utils/functions.sh

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

quiet="n"
generate_config_only="n"
incremental="y"

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

API_VERSION="14"

welcome() {
  echo -e "${COLOR}Welcome to installation of $solution_name${NC} "
  echo
  echo "The solution will be deployed with the following default values"
  print_configuration
  echo -n "Press n to change the configuration or Enter to continue: "
  read -r defaults
  defaults=$(convert_answer $defaults 'y')
  echo
}


setup() {
  # get default value from google-ads.yaml
  if [[ $defaults != "y" ]]; then
    echo "Please configure the solution. The default answers are specified in parentheses, press Enter to select them"
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
    # TODO: activate when incremental is ready
    #ask_for_incremental_saving
    start_date=${start_date:-:YYYYMMDD-90}
    end_date=${end_date:-:YYYYMMDD-1}

  fi
  generate_bq_macros

  if [[ -n $RUNNING_IN_GCE && $generate_config_only ]]; then
    # if you're running inside Google Cloud Compute Engine as generating config
    # (see gcp/cloud-run-button/main.sh) then there's no need for additional questions
    config_file="app/$solution_name_lowercase.yaml"
    save_config="--save-config --config-destination=$config_file"
    echo -e "${COLOR}Saving configuration to $config_file${NC}"
    if [[ $initial_load = "y" ]]; then
      fetch_reports $save_config --log=$loglevel --api-version=$API_VERSION --dry-run --macro.initial_load_date=$initial_load_date
    else
      fetch_reports $save_config --log=$loglevel --api-version=$API_VERSION --dry-run
    fi
    generate_output_tables $save_config --log=$loglevel --dry-run
    # TODO: activate when incremental is ready
    # save_to_config $config_file $incremental
    exit
  fi

  if [[ $defaults != "y" ]]; then
    echo -n "Do you want to save this config (Y/n): "
    read -r save_config_answer
    save_config_answer=$(convert_answer $save_config_answer 'Y')
    if [[ $save_config_answer = "y" ]]; then
      echo -n "Save config as ($solution_name_lowercase.yaml): "
      read -r config_file_name
      config_file_name=${config_file_name:-$solution_name_lowercase.yaml}
      config_file=$(echo "`echo $config_file_name | sed 's/\.yaml//'`.yaml")
    elif [[ $save_config_answer = "q" ]]; then
      exit
    else
      config_file="/tmp/$solution_name_lowercase.yaml"
    fi
  else
    config_file=$solution_name_lowercase.yaml
  fi
  save_config="--save-config --config-destination=$config_file"
  echo -e "${COLOR}Saving configuration to $config_file${NC}"
  if [[ $initial_load = "y" ]]; then
    fetch_reports $save_config --log=$loglevel --api-version=$API_VERSION --dry-run --macro.initial_load_date=$initial_load_date
  else
    fetch_reports $save_config --log=$loglevel --api-version=$API_VERSION --dry-run
  fi
  generate_output_tables $save_config --log=$loglevel --dry-run
  # TODO: activate when incremental is ready
  # save_to_config $config_file $incremental
  if [[ $generate_config_only = "y" ]]; then
    exit
  fi
  if [[ $defaults != "y" ]]; then
    print_configuration
  fi
}


print_configuration() {
  echo "Your configuration:"
  echo "  account_id: $customer_id"
  echo "  BigQuery project_id: $project"
  echo "  BigQuery dataset: $bq_dataset"
  echo "  Reporting window: Last $start_date_days days"
}

run_google_ads_queries() {
  echo -e "${COLOR}===fetching reports===${NC}"
    local config_file=${1:-$config_file}
    gaarf $(dirname $0)/google_ads_queries/**/*.sql -c=$config_file \
      --ads-config=$ads_config --log=$loglevel --api-version=$API_VERSION
}

run_bq_queries() {
  if [ -d "$(dirname $0)/bq_queries/snapshots/" ]; then
    echo -e "${COLOR}===generating snapshots===${NC}"
    gaarf-bq $(dirname $0)/bq_queries/snapshots/*.sql -c=$config_file --log=$loglevel
  fi
  if [ -d "$(dirname $0)/bq_queries/views/" ]; then
    echo -e "${COLOR}===generating views===${NC}"
    gaarf-bq $(dirname $0)/bq_queries/views/*.sql -c=$config_file --log=$loglevel
  fi
  echo -e "${COLOR}===generating output tables===${NC}"
  gaarf-bq $(dirname $0)/bq_queries/*.sql -c=$config_file --log=$loglevel
  if [ -d "$(dirname $0)/bq_queries/incremental/" ]; then
    if [[ $initial_load = "y" ]]; then
      echo -e "${COLOR}===performing initial load of performance data===${NC}"
      gaarf-bq $(dirname $0)/bq_queries/incremental/initial_load.sql \
        --project=`echo $project` --macro.output_dataset=`echo $output_dataset` \
        --macro.initial_date=`echo $initial_date` \
        --macro.start_date=`echo $start_date` --log=$loglevel
    else
      infer_answer_from_config $config_file incremental
      if [[ $incremental = "y" ]]; then
        echo -e "${COLOR}===saving incremental performance data===${NC}"
        gaarf-bq $(dirname $0)/bq_queries/incremental/incremental_saving.sql \
        --project=`echo $project` --macro.output_dataset=`echo $output_dataset` \
        --macro.initial_date=`echo $initial_date` \
        --macro.start_date=`echo $start_date` --log=$loglevel
      fi
    fi
  fi
}

run_with_config() {
  echo -e "${COLOR}Running with $config_file${NC}"
  if [[ -f "$config_file" ]]; then
    cat $config_file
  fi
  # TODO: activate when incremental is ready
  # check_initial_load
  if [[ $initial_load = "y" ]];
  then
    cat $config_file | sed '/start_date/d;' | \
            sed 's/initial_load_date/start_date/' > /tmp/$solution_name_lowercase.yaml
    runtime_config=/tmp/$solution_name_lowercase.yaml
  else
    runtime_config=$config_file
  fi
  run_google_ads_queries $runtime_config
  run_bq_queries
}

check_ads_config
#
# defaults
start_date_days=90
start_date=":YYYYMMDD-90"
end_date=":YYYYMMDD-1"
bq_dataset="dactionboard"
project=${GOOGLE_CLOUD_PROJECT:-$(gcloud config get-value project 2>/dev/null)}
parse_yaml $ads_config "GOOGLE_ADS_"
customer_id=$GOOGLE_ADS_login_customer_id
generate_bq_macros

if [[ -z ${loglevel} ]]; then
  loglevel="INFO"
fi

if [[ $generate_config_only = "y" ]]; then
  welcome
  setup
fi

if [[ -n "$config_file" || -f $solution_name_lowercase.yaml ]]; then
  config_file=${config_file:-$solution_name_lowercase.yaml}
  cat $config_file
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
      run_with_config $config_file
    elif [[ $setup_config_answer = "n" ]]; then
      echo -e "${COLOR}Setting up new configuration... (Press Ctrl + C to exit)${NC}"
      welcome
      setup
      prompt_running
      run_with_config
    else
      echo "Exiting"
      exit
    fi
  fi
else
  welcome
  setup
  prompt_running
  run_with_config
fi
