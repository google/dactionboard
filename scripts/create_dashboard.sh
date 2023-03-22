#!/bin/bash
## Copyright 2022 Google LLC
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

report_id=187f1f41-16bc-434d-8437-7988bed6e8b9
report_name="dactionboard_copy"
return_link=0

while :; do
case $1 in
	-c|--config)
		shift
		config=$1
		project_id=`grep -A1 "gaarf-bq" $config | tail -n1 | cut -d ":" -f 2 | tr -d " "`
		dataset_id=`grep output_dataset $config | tail -n1 | cut -d ":" -f 2 | tr -d " "`
		;;
	-p|--project)
		shift
		project_id=$1
		;;
	-d|--dataset)
		shift
		dataset_id=$1
		;;
  -L|--link)
    return_link=1
    ;;
	-n|--report-name)
		shift
		report_name=`echo "$1" | tr  " " "_"`
		;;
	--report-id)
		shift
		report_id=$1
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

link=`cat $(dirname $0)/linking_api.http | sed "s/REPORT_ID/$report_id/; s/REPORT_NAME/$report_name/; s/YOUR_PROJECT_ID/$project_id/g; s/YOUR_DATASET_ID/$dataset_id/g" | sed '/^$/d;' | tr -d '\n'`
if [ $return_link -eq 1 ]; then
  echo "$link"
else
  open "$link"
fi
