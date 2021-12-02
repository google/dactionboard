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

from typing import Sequence, Any
from google.cloud import bigquery  #type: ignore
from google.cloud.exceptions import NotFound  #type: ignore
import csv
import time
import pandas as pd  #type: ignore


def save_to_csv(results: Sequence[Sequence[Any]], column_names: Sequence[str],
                destination: str) -> None:
    """Saves output of data fetching to a local csv file.

    Args:
        results: Rows without headers to be written to CSV
        column_names: List containing names of column to be considers as
            header of CSV
        destination: location of file
    Returns:
        None
    """

    with open(destination, "w") as file:
        writer = csv.writer(file,
                            delimiter=",",
                            quotechar='"',
                            quoting=csv.QUOTE_MINIMAL)
        writer.writerow(column_names)
        writer.writerows(results)


def save_to_bq(client: bigquery.Client,
               project: str,
               dataset: str,
               table: str,
               results: pd.DataFrame,
               schema: Sequence[bigquery.SchemaField],
               location: str = "US") -> None:
    """Saves output of data fetching to BigQuery.

    Args:
        client: BigQuery client
        project: BigQuery project_id
        dataset: BigQuery dataset_id
        table: BigQuery table name
        results: dataframe containing data to be written to BigQuery
        schema: BigQuery schema for results
        location: location of dataset_id (if dataset does not exist and should
            be created)

    Returns:
        None
    """
    dataset_id = f"{project}.{dataset}"
    destination = f"{dataset_id}.{table}"
    try:
        client.get_dataset(dataset_id)
    except NotFound:
        bq_dataset = bigquery.Dataset(dataset_id)
        bq_dataset.location = location
        bq_dataset = client.create_dataset(bq_dataset, timeout=30)
    job_config = bigquery.LoadJobConfig(
        write_disposition=bigquery.WriteDisposition.WRITE_TRUNCATE,
        schema=schema)
    try:
        table = client.get_table(destination)
    except NotFound:
        table_ref = bigquery.Table(destination, schema=schema)
        table = client.create_table(table_ref)
        table = client.get_table(destination)
    client.load_table_from_dataframe(dataframe=results,
                                     destination=table,
                                     job_config=job_config)
