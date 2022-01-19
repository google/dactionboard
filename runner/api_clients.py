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
from google.ads.googleads.client import GoogleAdsClient  #type: ignore
from google.ads.googleads.v9.services.services.google_ads_service.client import GoogleAdsServiceClient  #type: ignore


class BaseClient:
    def get_response(self, entity_id: str, query_text: str):
        pass


class GoogleAdsApiClient(BaseClient):
    def __init__(self):
        self.client = GoogleAdsClient.load_from_storage(version="v9")
        self.ga_service = self.client.get_service("GoogleAdsService")

    def get_client(self):
        return self.ga_service

    def get_response(self, entity_id, query_text):
        response = self.ga_service.search_stream(customer_id=entity_id,
                                                 query=query_text)
        return response
