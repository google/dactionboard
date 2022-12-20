-- Copyright 2022 Google LLC
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     https://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
SELECT
    customer.id AS customer_id,
    campaign.id AS campaign_id,
    campaign_criterion.custom_audience.custom_audience AS custom_audience,
    campaign_criterion.display_name AS display_name,
    campaign_criterion.type AS type,
    user_interest.name AS user_interest,
    user_list.name AS user_list
FROM campaign_criterion
WHERE
    campaign_criterion.type IN (
	"CUSTOM_AUDIENCE",
	"USER_LIST"
    )
    AND campaign_criterion.status = "ENABLED"
    AND campaign_criterion.negative = FALSE
