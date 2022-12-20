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

config=$1
project_id=`grep -A1 "gaarf-bq" $config | tail -n1 | cut -d ":" -f 2 | tr -d " "`
dataset_id=`grep output_dataset $config | tail -n1 | cut -d ":" -f 2 | tr -d " "`

link=`cat $(dirname $0)/linking_api.http | sed "s/YOUR_PROJECT_ID/$project_id/g; s/YOUR_DATASET_ID/$dataset_id/g" | sed '/^$/d;' | tr -d '\n'`
echo
open $link || (echo "Please visit the link below to generate the dashboard: " && echo $link)
