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
    campaign.name AS campaign_name,
    campaign.status AS status,
    campaign.start_date AS start_date,
    campaign.end_date AS end_date,
    campaign.bidding_strategy_type AS bidding_strategy,
    campaign_budget.amount_micros AS budget_amount,
    campaign_budget.total_amount_micros AS total_budget,
    campaign_budget.type AS budget_type,
    campaign_budget.explicitly_shared AS is_shared_budget,
    campaign_budget.period AS budget_period,
    campaign.target_cpa.target_cpa_micros AS target_cpa,
    campaign.target_roas.target_roas AS target_roas,
    campaign.maximize_conversions.target_cpa AS max_conv_target_cpa,
    campaign.selective_optimization.conversion_actions AS selective_optimization_conversion_actions,
    metrics.cost_micros AS cost,
    metrics.conversions AS conversions
FROM campaign
WHERE campaign.advertising_channel_type = "VIDEO"
    AND campaign.bidding_strategy_type IN (
        "MAXIMIZE_CONVERSIONS",
        "TARGET_CPA"
    )
    AND segments.date >= "{start_date}"
    AND segments.date <= "{end_date}"
