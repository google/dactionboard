CREATE OR REPLACE TABLE {bq_project}.{bq_dataset}.device_performance_F
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
    AP.device,
    SUM(AP.clicks) AS clicks,
    SUM(AP.impressions) AS impressions,
    SUM(AP.all_conversions) AS all_conversions,
    SUM(AP.conversions) AS conversions,
    SUM(AP.video_views) AS video_views,
    SUM(view_through_conversions) AS view_through_conversions,
    SUM(AP.engagements) AS engagements,
    ROUND(SUM(AP.cost) / 1e6) AS cost
FROM {bq_project}.{bq_dataset}.ad_performance AS AP
INNER JOIN {bq_project}.{bq_dataset}.mapping AS M
  ON AP.campaign_id = M.campaign_id
GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11);
