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
CREATE OR REPLACE TABLE `{output_dataset}.video_conversion_split`
AS (
WITH PerformanceTable AS (
    SELECT
        date,
        ad_group_id,
        ad_id,
        SUM(cost) AS cost
    FROM `{bq_dataset}.ad_performance`
    GROUP BY 1, 2, 3
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
    AP.ad_id,
    AM.youtube_video_id,
    AM.youtube_title AS video_title,
    ROUND(AM.youtube_video_duration / 1000) AS video_duration,
    AP.conversion_name,
    SUM(P.cost / 1e6) AS cost,
    SUM(IFNULL(AP.all_conversions, 0)) AS all_conversions,
    SUM(IFNULL(AP.conversions, 0)) AS conversions,
    SUM(IFNULL(AP.view_through_conversions, 0)) AS view_through_conversions
FROM PerformanceTable AS P
LEFT JOIN `{bq_dataset}.conversion_split` AS AP
    USING(ad_group_id, date, ad_id)
INNER JOIN `{bq_dataset}.mapping` AS M
  ON AP.ad_group_id = M.ad_group_id
INNER JOIN `{bq_dataset}.ad_matching` AS AM
  ON AP.ad_id = AM.ad_id
GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16);
