CREATE OR REPLACE TABLE {bq_project}.{bq_dataset}.ad_video_performance_F
AS (
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
    AM.ad_name AS ad_name,
    AM.youtube_video_id,
    AM.youtube_title AS video_title,
    AM.youtube_video_duration AS video_duration,
    COALESCE(V.headlines, V.long_headlines) AS headlines,
    COALESCE(V.call_to_actions, V.action_button_label) AS call_to_action,
    Assets.url AS companion_banner_url,
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
INNER JOIN {bq_project}.{bq_dataset}.video_headlines_call_to_actions AS V
  ON AP.ad_id = V.ad_id
INNER JOIN {bq_project}.{bq_dataset}.mapping AS M
  ON AP.ad_group_id = M.ad_group_id
INNER JOIN {bq_project}.{bq_dataset}.asset_mapping AS Assets
  ON V.companion_banner = CAST(Assets.asset_id AS STRING)
GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18);
