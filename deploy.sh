#!/bin/bash
COLOR='\033[0;36m' # Cyan
NC='\033[0m' # No color

solution_name="dActionBoard"
solution_name_lowercase=$(echo $solution_name | tr '[:upper:]' '[:lower:]' |\
	tr ' ' '_')

# Specify customer ids query that fetch data only from accounts that have at least one app campaign in them.
customer_ids_query='SELECT customer.id FROM ad_group WHERE ad_group.type IN ("VIDEO_RESPONSIVE", "VIDEO_TRUE_VIEW_IN_DISPLAY", "VIDEO_TRUE_VIEW_IN_STREAM") AND campaign.bidding_strategy_type IN ("MAXIMIZE_CONVERSIONS", "TARGET_CPA")'

GOOGLE_ADS_API_VERSION=10

check_ads_config() {
	if [[ -f "$HOME/google-ads.yaml" ]]; then
		ads_config=$HOME/google-ads.yaml
	else
		echo -n "Enter full path to google-ads.yaml file: "
		read -r ads_config
	fi
}

setup() {
	echo -n "Enter account_id: "
	read -r customer_id
	echo -n "Enter BigQuery project_id: "
	read -r project
	echo -n "Enter BigQuery dataset: "
	read -r bq_dataset
	echo -n "Enter start_date in YYYY-MM-DD format: "
	read -r start_date
	echo -n "Enter end_date in YYYY-MM-DD format: "
	read -r end_date
	echo  "Script are expecting google-ads.yaml file in your home directory"
	echo -n "Is the file there (Y/n): "
	read -r ads_config_answer
	if [[ $ads_config_answer = "Y" ]]; then
		ads_config=$HOME/google-ads.yaml
	else
		echo -n "Enter full path to google-ads.yaml file: "
		read -r ads_config
	fi
	echo -n "Do you want to save this config (Y/n): "
	read -r save_config_answer
	if [[ $save_config_answer = "Y" ]]; then
		save_config="--save-config --config-destination=$solution_name_lowercase.yaml"
	fi
	print_configuration
}


deploy() {
	echo -n -e "${COLOR}Deploy $solution_name? Y/n/q: ${NC}"
	read -r answer

	if [[ $answer = "Y" ]]; then
		echo "Deploying..."
	elif [[ $answer = "q" ]]; then
		exit 1
	else
		setup
	fi
	generate_parameters
}

generate_parameters() {
	macros="--macro.bq_project=$project --macro.bq_dataset=$bq_dataset"
}


fetch_reports() {
	echo -e "${COLOR}===fetching reports===${NC}"
	gaarf google_ads_queries/*/*.sql \
	--account=$customer_id \
	--output=bq \
	--customer-ids-query="$customer_ids_query" \
	--bq.project=$project --bq.dataset=$bq_dataset \
	--macro.start_date=$start_date --macro.end_date=$end_date \
	--api-version=$GOOGLE_ADS_API_VERSION \
	--ads-config=$ads_config "$@"
}

generate_output_tables() {
	echo -e "${COLOR}===generating final tables===${NC}"
	gaarf-bq bq_queries/*.sql \
		--project=$project --target=$bq_dataset $macros "$@"
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
	gaarf google_ads_queries/**/*.sql -c=$solution_name_lowercase.yaml \
		--ads-config=$ads_config
	echo -e "${COLOR}===generating final tables===${NC}"
	gaarf-bq bq_queries/*.sql -c=$solution_name_lowercase.yaml

}

welcome
check_ads_config

if [[ -f "$solution_name_lowercase.yaml" ]]; then
	echo -e "${COLOR}Found saved configuration at $solution_name_lowercase.yaml${NC}"
	cat $solution_name_lowercase.yaml
	echo -n -e "${COLOR}Do you want to use it (Y/n): ${NC}"
	read -r setup_config_answer
	if [[ $setup_config_answer = "Y" ]]; then
		echo -e "${COLOR}Using saved configuration...${NC}"
	fi
	run_with_config
else
	get_input
	fetch_reports $save_config
	generate_output_tables $save_config
fi
