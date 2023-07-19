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
    ad_group.id AS ad_group_id,
    ad_group.optimized_targeting_enabled AS is_auto_targeting,
    ad_group_criterion.criterion_id AS criterion_id,
    ad_group_criterion.negative AS is_negative,
    ad_group_criterion.custom_audience.custom_audience AS custom_audience,
    ad_group_criterion.custom_intent.custom_intent AS custom_intent,
    ad_group_criterion.display_name AS display_name,
    ad_group_criterion.type AS type,
    user_interest.name AS user_interest,
    user_list.name AS user_list
FROM ad_group_criterion
WHERE
    ad_group_criterion.type IN (
	"CUSTOM_AUDIENCE",
	"USER_LIST"
    )
    AND ad_group_criterion.status = "ENABLED"
    AND ad_group_criterion.negative = FALSE
    AND campaign.bidding_strategy_type IN (
	"MAXIMIZE_CONVERSIONS",
	"TARGET_CPA"
    )
