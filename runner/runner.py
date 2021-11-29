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
# limitations under the License.from google.ads.googleads.client import GoogleAdsClient

from google.ads.googleads.client import GoogleAdsClient
from google.ads.googleads.errors import GoogleAdsException
import re
from operator import attrgetter
import argparse
from pathlib import Path
from google.cloud import bigquery
import pandas as pd

import utils
from query_editor import get_query_elements
import writer
import api_handler

parser = argparse.ArgumentParser()
parser.add_argument("query", nargs="+")
parser.add_argument("--customer_id", dest="customer_id")
parser.add_argument("--save", dest="save", default="csv")
parser.add_argument("-p", dest="print", default=False)
parser.add_argument("--destination", dest="destination")
parser.add_argument("--bq_project", dest="bq_project")
parser.add_argument("--bq_dataset", dest="bq_dataset")
parser.add_argument("--start_date", dest="start_date")
parser.add_argument("--end_date", dest="end_date")
args = parser.parse_args()

customer_id = args.customer_id
if args.save == "bq":
    bq_client = bigquery.Client()

googleads_client = GoogleAdsClient.load_from_storage(version="v8")
ga_service = googleads_client.get_service("GoogleAdsService")

# Get all customer_ids under MCC account
print("getting customers")
customer_ids = api_handler.get_customer_ids(ga_service, customer_id)
print("got customers")

for query in args.query:
    sql_path = Path(query)
    csv_output_path = sql_path.name.replace('.sql', '.csv')
    bq_table_name = sql_path.name.replace('.sql', '')

    # read Ads query from file
    query_text, fields, column_names, pointers, nested_fields, resource_indices = get_query_elements(sql_path)
    query_text = utils.format_ads_query(query_text)
    query_text = query_text.format(start_date = args.start_date, end_date = args.end_date)
    print(query_text)
    getter = attrgetter(*fields)
    results = []
    results_types = {}

    for customer_id, name in customer_ids.items():
        response = ga_service.search_stream(customer_id=customer_id,
                                            query=query_text)
        for batch in response:
            for row in batch.results:
                row_ = getter(row)
                elements = []
                for i, r in enumerate(row_):
                    try:
                        element = r.name
                        results_types[column_names[i]] = {
                            "element_type": type(element)
                        }
                    except:
                        try:
                            element = r.text
                            elements.append(element)
                            results_types[column_names[i]] = {
                                "element_type": type(element)
                            }
                        except:
                            if pointers.get(fields[i]):
                                try:
                                    element = [
                                        utils.extract_resource(v) for v in r
                                    ]
                                except:
                                    element = r
                            elif nested_fields.get(fields[i]):
                                try:
                                    for field in nested_fields.get(fields[i]):
                                        new_getter = attrgetter(field)
                                        print(f"{field}: {new_getter(r)}")
                                        element = new_getter(r)
                                except:
                                    pass
                            else:
                                element = r
                            results_types[column_names[i]] = {
                                "element_type": type(r)
                            }
                    if resource_indices.get(fields[i]):
                        element = utils.extract_id_from_resource(element, 1)
                    elements.append(element)
                results.append(elements)

    if args.print:
        print(",".join(column_names))
        print(results)
    if args.save == "csv":
        writer.save_to_csv(results, column_names, args.destination
                           or csv_output_path)
    elif args.save == "bq":
        if not args.bq_project and args.bq_dataset:
            raise ValueError(
                "--bq_project and --bq_dataset parameters must be specified when saving to BigQuery!"
            )
        schema = utils.get_bq_schema(results_types)
        df = pd.DataFrame(results, columns = column_names)
        writer.save_to_bq(bq_client, args.bq_project, args.bq_dataset,
                          bq_table_name, df, schema)
