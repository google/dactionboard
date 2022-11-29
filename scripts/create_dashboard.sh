config=$1
project_id=`grep -A1 "gaarf-bq" $config | tail -n1 | cut -d ":" -f 2 | tr -d " "`
dataset_id=`grep output_dataset $config | tail -n1 | cut -d ":" -f 2 | tr -d " "`

link=`cat $(dirname $0)/linking_api.http | sed "s/YOUR_PROJECT_ID/$project_id/g; s/YOUR_DATASET_ID/$dataset_id/g" | sed '/^$/d;' | tr -d '\n'`
echo
open $link || (echo "Please visit the link below to generate the dashboard: " && echo $link)
