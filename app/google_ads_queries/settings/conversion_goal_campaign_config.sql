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
    campaign.id AS campaign_id,
    custom_conversion_goal.conversion_actions AS actions
FROM conversion_goal_campaign_config
WHERE campaign.advertising_channel_type = "VIDEO"
    AND campaign.bidding_strategy_type IN (
        "MAXIMIZE_CONVERSIONS",
        "TARGET_CPA"
    )
