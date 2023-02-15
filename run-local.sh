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
		google_ads_config=$1
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

GOOGLE_ADS_API_VERSION=12

check_ads_config() {
	if [[ -n $google_ads_config ]]; then
		ads_config=$google_ads_config
	elif [[ -f "$HOME/google-ads.yaml" ]]; then
		ads_config=$HOME/google-ads.yaml
	else
		echo -n "Enter full path to google-ads.yaml file: "
		read -r ads_config
	fi
}

convert_answer() {
	echo "$1" | tr '[:upper:]' '[:lower:]' | cut -c1
}

setup() {
	echo -n "Enter account_id: "
	read -r customer_id
	echo -n "Enter BigQuery project_id: "
	read -r project
	echo -n "Enter BigQuery dataset: "
	read -r bq_dataset
	echo -n "Enter start_date in YYYY-MM-DD format (or use :YYYYMMDD-30 for last 30 days): "
	read -r start_date
	echo -n "Enter end_date in YYYY-MM-DD format (or use :YYYYMMDD-1 for yesterday): "
	read -r end_date
	echo  "Script are expecting google-ads.yaml file in your home directory"
	echo -n "Is the file there (Y/n): "
	read -r ads_config_answer
	ads_config_answer=$(convert_answer $ads_config_answer)
	if [[ $ads_config_answer = "y" ]]; then
		ads_config=$HOME/google-ads.yaml
	else
		echo -n "Enter full path to google-ads.yaml file: "
		read -r ads_config
	fi
	echo -n "Do you want to save this config (Y/n): "
	read -r save_config_answer
	save_config_answer=$(convert_answer $save_config_answer)
	if [[ $save_config_answer = "y" ]]; then
		save_config="--save-config --config-destination=$solution_name_lowercase.yaml"
	elif [[ $save_config_answer = "q" ]]; then
		exit 1
	fi
	print_configuration
}


deploy() {
	echo -n -e "${COLOR}Deploy $solution_name? Y/n/q: ${NC}"
	read -r answer
	answer=$(convert_answer $answer)

	if [[ $answer = "y" ]]; then
		echo "Deploying..."
	elif [[ $answer = "q" ]]; then
		exit 1
	else
		setup
	fi
	generate_parameters
}

generate_parameters() {
	bq_dataset_output=$(echo $bq_dataset"_output")
	macros="--macro.bq_dataset=$bq_dataset --macro.output_dataset=$bq_dataset_output"
}


fetch_reports() {
	echo -e "${COLOR}===fetching reports===${NC}"
	gaarf $(dirname $0)/google_ads_queries/*/*.sql \
	--account=$customer_id \
	--output=bq \
	--customer-ids-query="$customer_ids_query" \
	--bq.project=$project --bq.dataset=$bq_dataset \
	--macro.start_date=$start_date --macro.end_date=$end_date \
	--ads-config=$ads_config "$@"
}

generate_output_tables() {
	echo -e "${COLOR}===generating final tables===${NC}"
	gaarf-bq $(dirname $0)/bq_queries/*.sql \
		--project=$project --target=$bq_dataset_output $macros "$@"
}


print_configuration() {
	echo "Your configuration:"
	echo "	account_id: $customer_id"
	echo "	BigQuery project_id: $project"
	echo "	BigQuery dataset:: $bq_dataset"
	echo "	Start date: $start_date"
	echo "	End date: $end_date"
	echo "	Ads config: $ads_config"
}

welcome() {
	echo -e "${COLOR}Welcome to installation of $solution_name${NC} "
}

get_input() {
	setup
	deploy
}


run_with_config() {
	echo -e "${COLOR}===fetching reports===${NC}"
	gaarf $(dirname $0)/google_ads_queries/**/*.sql -c=$config_file \
		--ads-config=$ads_config --log=$loglevel --api-version=$API_VERSION
	echo -e "${COLOR}===generating output tables===${NC}"
	gaarf-bq $(dirname $0)/bq_queries/*.sql -c=$config_file --log=$loglevel
}

check_ads_config

if [[ -z ${loglevel} ]]; then
	loglevel="INFO"
fi

if [[ -f "$config_file" ]]; then
	if [[ $quiet = "n" ]]; then
		echo -e "${COLOR}Found saved configuration at $config_file${NC}"
		cat $config_file
		echo -n -e "${COLOR}Do you want to use it (Y/n/q): ${NC}"
		read -r setup_config_answer
		setup_config_answer=$(convert_answer $setup_config_answer)
		if [[ $setup_config_answer = "y" ]]; then
			echo -e "${COLOR}Using saved configuration...${NC}"
			run_with_config
		elif [[ $setup_config_answer = "q" ]]; then
			exit 1
		else
			echo
			welcome
			get_input
		fi
	else
		run_with_config
	fi
else
	welcome
	get_input
	fetch_reports $save_config --log=$loglevel --api-version=$API_VERSION
	generate_output_tables $save_config --log=$loglevel
fi
