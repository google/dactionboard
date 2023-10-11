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
CREATE OR REPLACE TABLE `{output_dataset}.video_performance`
AS (
WITH CustomConvSplit AS (
        SELECT
            date,
            ad_id,
            {% for custom_conversion in custom_conversions %}
                {% for conversion_alias, conversion_name in custom_conversion.items() %}
                    SUM(IF(conversion_name IN ('{{conversion_name}}'), all_conversions, 0)) AS conversions_{{conversion_alias}},
                {% endfor %}
            {% endfor %}
        FROM `{bq_dataset}.conversion_split` AS AP
        GROUP BY 1,2
    )
SELECT
    PARSE_DATE("%Y-%m-%d", AP.date) AS day,
    M.account_id,
    M.account_name,
    M.currency,
    M.campaign_id,
    M.campaign_name,
    M.campaign_status,
    M.bidding_strategy,
    M.ad_group_id,
    M.ad_group_name,
    M.ad_group_status,
    SUM(AP.clicks) AS clicks,
    SUM(AP.impressions) AS impressions,
    SUM(AP.all_conversions) AS all_conversions,
    SUM(AP.conversions) AS conversions,
    SUM(AP.video_views) AS video_views,
    SUM(AP.view_through_conversions) AS view_through_conversions,
    {% for custom_conversion in custom_conversions %}
        {% for conversion_alias, conversion_name in custom_conversion.items() %}
            SUM(COALESCE(CCS.conversions_{{conversion_alias}}, 0)) AS conversions_{{conversion_alias}},
        {% endfor %}
    {% endfor %}
    SUM(AP.engagements) AS engagements,
    ROUND(SUM(AP.cost) / 1e6) AS cost
FROM `{bq_dataset}.ad_performance` AS AP
INNER JOIN `{bq_dataset}.mapping` AS M
  ON AP.ad_group_id = M.ad_group_id
LEFT JOIN CustomConvSplit AS CCS
  ON AP.ad_id = CCS.ad_id
    AND AP.date = CCS.date
GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11);
