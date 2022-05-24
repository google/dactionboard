CREATE OR REPLACE TABLE {bq_project}.{bq_dataset}.ad_video_performance_F
AS (
WITH
    GeoConstants AS (
        SELECT DISTINCT
            constant_id,
            country_code,
            name
        FROM {bq_project}.{bq_dataset}.geo_target_constant
    ),
    TargetingTable AS (
        SELECT
            M.campaign_id,
            M.ad_group_id,
            ARRAY_AGG(DISTINCT D.device_type ORDER BY D.device_type) AS devices,
            ARRAY_AGG(DISTINCT GT.name ORDER BY GT.name) AS locations,
            ARRAY_AGG(DISTINCT IFNULL(CA.display_name, "")) AS campaign_audiences,
            ARRAY_AGG(DISTINCT IFNULL(AA.display_name, "")) AS ad_group_audiences,
            ARRAY_AGG(DISTINCT IFNULL(T.topic, "")) AS topics
        FROM {bq_project}.{bq_dataset}.mapping AS M
        LEFT JOIN {bq_project}.{bq_dataset}.targeting_devices AS D
            ON M.campaign_id = D.campaign_id
        LEFT JOIN {bq_project}.{bq_dataset}.targeting_country AS C
            ON M.campaign_id = C.campaign_id
        LEFT JOIN {bq_project}.{bq_dataset}.targeting_audiences_campaign AS CA
            ON M.campaign_id = CA.campaign_id
        LEFT JOIN {bq_project}.{bq_dataset}.targeting_audiences_adgroup AS AA
            ON M.ad_group_id = AA.ad_group_id
        LEFT JOIN {bq_project}.{bq_dataset}.targeting_topics AS T
            ON M.campaign_id = T.ad_group_id
        INNER JOIN GeoConstants AS GT
          ON CAST( SPLIT(C.location, "/")[OFFSET(1)] AS INT64) = GT.constant_id
        GROUP BY 1, 2
    )
SELECT
    PARSE_DATE("%Y-%m-%d", AP.date) AS day,
    M.account_id,
    M.account_name,
    M.currency,
    M.campaign_id,
    M.campaign_name,
    M.campaign_status,
    M.ad_group_id,
    M.ad_group_name,
    M.ad_group_status,
    AP.ad_id AS ad_id,
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
    SUM(AP.video_views) AS video_views,
    SUM(AP.view_through_conversions) AS view_through_conversions,
    SUM(AP.engagements) AS engagements,
    ROUND(SUM(AP.cost) / 1e6) AS cost
FROM {bq_project}.{bq_dataset}.ad_performance AS AP
INNER JOIN {bq_project}.{bq_dataset}.ad_matching AS AM
  ON AP.ad_id = AM.ad_id
LEFT JOIN {bq_project}.{bq_dataset}.video_headlines_call_to_actions AS V
  ON AP.ad_id = V.ad_id
LEFT JOIN {bq_project}.{bq_dataset}.mapping AS M
  ON AP.ad_group_id = M.ad_group_id
LEFT JOIN {bq_project}.{bq_dataset}.asset_mapping AS Assets
  ON V.companion_banner = CAST(Assets.asset_id AS STRING)
LEFT JOIN {bq_project}.{bq_dataset}.asset_mapping AS Assets2
  ON V.companion_banners = CAST(Assets.asset_id AS STRING)
LEFT JOIN TargetingTable AS TT
    ON M.campaign_id = TT.campaign_id
        AND M.ad_group_id = M.ad_group_id
GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22);
