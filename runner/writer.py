# Copyright 2021 Google LLC
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
# limitations under the License.import csv

from google.cloud import bigquery
from google.cloud.exceptions import NotFound
import csv
import time


def save_to_csv(results, column_names, destination):
    with open(destination, "w") as file:
        writer = csv.writer(file,
                            delimiter=",",
                            quotechar='"',
                            quoting=csv.QUOTE_MINIMAL)
        writer.writerow(column_names)
        writer.writerows(results)


def save_to_bq(client, project, dataset, table, results, schema):
    destination = f"{project}.{dataset}.{table}"
    job_config = bigquery.LoadJobConfig(
        write_disposition=bigquery.WriteDisposition.WRITE_TRUNCATE
    )
    try:
        table = client.get_table(destination)
    except NotFound:
        table_ref = bigquery.Table(destination, schema=schema)
        table = client.create_table(table_ref)
        table = client.get_table(destination)
    client.load_table_from_dataframe(
        dataframe = results,
        destination = table,
        job_config = job_config)
