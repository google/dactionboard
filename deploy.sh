#!/bin/bash
solution_name="dActionBoard"
solution_name_lowercase=$(echo $solution_name | tr '[:upper:]' '[:lower:]' |\
	tr ' ' '_')

welcome() {
echo "Welcome to installation of $solution_name"
	if [[ -f "$solution_name_lowercase.config" ]]; then
		read_config
		echo "Found saved configuration at $solution_name_lowercase.config"
		print_configuration
		echo -n "Do you want to use it (Y/n): "
		read -r setup_config_answer
		if [[ $setup_config_answer = "Y" ]]; then
			echo "Using saved configuration..."
		else
			echo "Creating new configuration..."
			setup
		fi
	else
		setup
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
		save_config
	fi
	print_configuration
}

save_config() {
	declare -A setup_config
	setup_config["customer_id"]=$customer_id
	setup_config["project"]=$project
	setup_config["bq_dataset"]=$bq_dataset
	setup_config["start_date"]=$start_date
	setup_config["end_date"]=$end_date
	setup_config["ads_config"]=$ads_config
	declare -p setup_config > "$solution_name_lowercase.config"
}

read_config() {
	declare -A config
	source -- "$solution_name_lowercase.config"
	customer_id=${setup_config["customer_id"]}
	project=${setup_config["project"]}
	bq_dataset=${setup_config["bq_dataset"]}
	start_date=${setup_config["start_date"]}
	end_date=${setup_config["end_date"]}
	ads_config=${setup_config["ads_config"]}
}

deploy() {
	echo -n "Deploy $solution_name? Y/n/q: "
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
	echo "===fetching reports==="
	gaarf google_ads_queries/*/*.sql \
	--account=$customer_id \
	--output=bq \
	--bq.project=$project --bq.dataset=$bq_dataset \
	--macro.start_date=$start_date --macro.end_date=$end_date \
	--ads-config=$ads_config
}

generate_output_tables() {
	echo "===generating final tables==="
	gaarf-bq bq_queries/*.sql \
		--project=$project --target=$bq_dataset $macros
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

get_input() {
	welcome
	deploy
}

if [[ -f "$solution_name_lowercase.config"  && "$1" = "-s" ]]; then
	read_config
else
	get_input
fi

fetch_reports
generate_output_tables
