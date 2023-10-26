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
    segments.date AS date,
    campaign.id AS campaign_id,
    campaign.bidding_strategy_type AS bidding_strategy_type,
    ad_group.id AS ad_group_id,
    ad_group.type AS ad_group_type,
    ad_group_ad.ad.id AS ad_id,
    ad_group_ad.ad.name AS ad_name,
    segments.device AS device,
    metrics.clicks AS clicks,
    metrics.impressions AS impressions,
    metrics.cost_micros AS cost,
    metrics.conversions AS conversions,
    metrics.all_conversions AS all_conversions,
    metrics.view_through_conversions AS view_through_conversions,
    metrics.video_views AS video_views,
    metrics.engagements AS engagements
FROM ad_group_ad
WHERE
    segments.date >= "{start_date}"
    AND segments.date <= "{end_date}"
    AND ad_group.type IN (
      "VIDEO_RESPONSIVE",
      "VIDEO_TRUE_VIEW_IN_DISPLAY",
      "VIDEO_TRUE_VIEW_IN_STREAM"
    )
    AND campaign.bidding_strategy_type IN (
      "MAXIMIZE_CONVERSIONS",
      "TARGET_CPA"
    )
