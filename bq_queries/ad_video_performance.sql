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
CREATE OR REPLACE TABLE `{output_dataset}.ad_video_performance`
AS (
WITH
    GeoConstants AS (
        SELECT DISTINCT
            constant_id,
            country_code,
            name
        FROM `{bq_dataset}.geo_target_constant`
    ),
    DevicesTable AS (
        SELECT
            campaign_id,
            ARRAY_AGG(DISTINCT device_type ORDER BY device_type) AS devices
        FROM `{bq_dataset}.targeting_devices`
        GROUP BY 1
    ),
    LocationsTable AS (
        SELECT
            campaign_id,
            ARRAY_AGG(DISTINCT GT.name ORDER BY GT.name) AS locations,
        FROM `{bq_dataset}.targeting_country` AS C
        INNER JOIN GeoConstants AS GT
            ON CAST( SPLIT(C.location, "/")[SAFE_OFFSET(1)] AS INT64) = GT.constant_id
        GROUP BY 1
    ),
    CampaignAudiencesTable AS (
        SELECT
            campaign_id,
            ARRAY_AGG(DISTINCT IFNULL(display_name, "")) AS campaign_audiences
        FROM `{bq_dataset}.targeting_audiences_campaign`
        GROUP BY 1
    ),
    AdGroupAudiencesTable AS (
        SELECT
            ad_group_id,
            ARRAY_AGG(DISTINCT IFNULL(display_name, "")) AS ad_group_audiences
        FROM `{bq_dataset}.targeting_audiences_adgroup`
        GROUP BY 1
    ),
    TopicsTable AS (
        SELECT
            ad_group_id,
            ARRAY_AGG(DISTINCT IFNULL(topic, "")) AS topics
        FROM `{bq_dataset}.targeting_topics`
        GROUP BY 1
    ),
    MappingTable AS (
        SELECT
            ad_group_id,
            ANY_VALUE(ad_group_name) AS ad_group_name,
            ANY_VALUE(ad_group_status) AS ad_group_status,
            ANY_VALUE(campaign_id) AS campaign_id,
            ANY_VALUE(campaign_name) AS campaign_name,
            ANY_VALUE(campaign_status) AS campaign_status,
            ANY_VALUE(bidding_strategy) AS bidding_strategy,
            ANY_VALUE(account_id) AS account_id,
            ANY_VALUE(account_name) AS account_name,
            ANY_VALUE(currency) AS currency
        FROM `{bq_dataset}.mapping`
        GROUP BY 1
    ),
    AdGroupTargetingTable AS (
        SELECT
            M.ad_group_id,
            M.campaign_id,
            ad_group_audiences,
            topics
        FROM MappingTable AS M
        LEFT JOIN AdGroupAudiencesTable AS AA
            ON M.ad_group_id = AA.ad_group_id
        LEFT JOIN TopicsTable AS T
            ON M.ad_group_id = T.ad_group_id
    ),
    TargetingTable AS (
        SELECT
            M.campaign_id,
            M.ad_group_id,
            D.devices,
            L.locations,
            CA.campaign_audiences,
            M.ad_group_audiences,
            M.topics
        FROM AdGroupTargetingTable AS M
        LEFT JOIN DevicesTable AS D
            ON M.campaign_id = D.campaign_id
        LEFT JOIN LocationsTable AS L
            ON M.campaign_id = L.campaign_id
        LEFT JOIN CampaignAudiencesTable AS CA
            ON M.campaign_id = CA.campaign_id
    ),
    AdMatchingTable AS(
        SELECT
            ad_id,
            ANY_VALUE(youtube_video_id) AS youtube_video_id,
            ANY_VALUE(youtube_title) AS youtube_title,
            ANY_VALUE(youtube_video_duration) AS youtube_video_duration
        FROM `{bq_dataset}.ad_matching`
        GROUP BY 1
    ),
    CustomConvSplit AS (
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
    AP.ad_id AS ad_id,
    AP.ad_name AS ad_name,
    AM.youtube_video_id,
    AM.youtube_title AS video_title,
    ROUND(AM.youtube_video_duration/1000) AS video_duration,
    COALESCE(V.headlines, V.long_headlines) AS headlines,
    CASE WHEN V.call_to_actions != "" and V.call_to_actions IS NOT NULL
            THEN call_to_actions
        WHEN V.action_button_label != "" AND V.action_button_label IS NOT NULL
            THEN action_button_label
        ELSE ""
    END AS call_to_action,
    COALESCE(Assets.url, Assets2.url) AS companion_banner_url,
    ARRAY_TO_STRING(TT.campaign_audiences, " | ") AS campaign_audiences,
    ARRAY_TO_STRING(TT.ad_group_audiences, " | ") AS ad_group_audiences,
    ARRAY_TO_STRING(TT.devices, " | ") AS devices,
    ARRAY_TO_STRING(TT.topics, " | ") AS topics,
    IF(ARRAY_LENGTH(TT.locations)=221, "All", ARRAY_TO_STRING(TT.locations, " | ")) AS locations,
    SUM(AP.clicks) AS clicks,
    SUM(AP.impressions) AS impressions,
    SUM(AP.all_conversions) AS all_conversions,
    SUM(AP.conversions) AS conversions,
    {% for custom_conversion in custom_conversions %}
        {% for conversion_alias, conversion_name in custom_conversion.items() %}
            SUM(COALESCE(CCS.conversions_{{conversion_alias}}, 0)) AS conversions_{{conversion_alias}},
        {% endfor %}
    {% endfor %}
    SUM(AP.video_views) AS video_views,
    SUM(AP.view_through_conversions) AS view_through_conversions,
    SUM(AP.engagements) AS engagements,
    ROUND(SUM(AP.cost) / 1e6) AS cost
FROM `{bq_dataset}.ad_performance` AS AP
INNER JOIN AdMatchingTable AS AM
  ON AP.ad_id = AM.ad_id
LEFT JOIN `{bq_dataset}.video_headlines_call_to_actions` AS V
  ON AP.ad_id = V.ad_id
LEFT JOIN CustomConvSplit AS CCS
  ON AP.ad_id = CCS.ad_id
    AND AP.date = CCS.date
LEFT JOIN MappingTable AS M
  ON AP.ad_group_id = M.ad_group_id
LEFT JOIN `{bq_dataset}.asset_mapping` AS Assets
  ON V.in_stream_companion_banner = CAST(Assets.asset_id AS STRING)
LEFT JOIN `{bq_dataset}.asset_mapping` AS Assets2
  ON V.responsive_companion_banner = CAST(Assets2.asset_id AS STRING)
LEFT JOIN TargetingTable AS TT
    ON M.ad_group_id = TT.ad_group_id
GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24);
