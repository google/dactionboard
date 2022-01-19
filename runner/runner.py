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
# limitations under the License.

from concurrent import futures
from typing import Any, Callable, Dict, Sequence

from google.ads.googleads.client import GoogleAdsClient  #type: ignore
from google.ads.googleads.v9.services.services.google_ads_service.client import GoogleAdsServiceClient  #type: ignore
from operator import attrgetter
from itertools import repeat

import arg_parser
import parsers
import writer
import api_handler
import api_clients
import query_editor

args = arg_parser.parse_cli_args()

ga_service = api_clients.GoogleAdsApiClient().get_client()

google_ads_row_parser = parsers.GoogleAdsRowParser()

writer_factory = writer.WriterFactory()
writer_client = writer_factory.create_writer(args.save, **vars(args))

customer_ids = api_handler.get_customer_ids(ga_service, args.customer_id)


def process_query(query: str, customer_ids: Dict[str, str],
                  api_client: GoogleAdsServiceClient,
                  parser: parsers.BaseParser,
                  writer_client: writer.AbsWriter) -> None:
    query_elements = query_editor.get_query_elements(query)
    query_text = query_elements.query_text.format(start_date=args.start_date,
                                                  end_date=args.end_date)
    print(query_text)
    getter = attrgetter(*query_elements.fields)
    total_results = []
    for customer_id in customer_ids:
        response = api_client.search_stream(customer_id=customer_id,
                                            query=query_text)
        for batch in response:
            results = [
                api_handler.parse_ads_row(row, getter, parser)
                for row in batch.results
            ]
            total_results.extend(results)

    output = writer_client.write(total_results, query, query_elements.column_names)
    print(f"data is saved - {output}")


with futures.ThreadPoolExecutor() as executor:
    results = executor.map(process_query, args.query, repeat(customer_ids),
                           repeat(ga_service), repeat(google_ads_row_parser),
                           repeat(writer_client))
