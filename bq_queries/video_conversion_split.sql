CREATE OR REPLACE TABLE {bq_project}.{bq_dataset}.video_conversion_split_F
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
    AP.ad_id,
    AM.youtube_video_id,
    AM.youtube_title AS video_title,
    ROUND(Media.youtube_video_duration / 1000) AS video_duration,
    AP.conversion_name,
    SUM(AP.all_conversions) AS all_conversions,
    SUM(AP.conversions) AS conversions,
    SUM(AP.view_through_conversions) AS view_through_conversions
FROM {bq_project}.{bq_dataset}.conversion_split AS AP
INNER JOIN {bq_project}.{bq_dataset}.mapping AS M
  ON AP.ad_group_id = M.ad_group_id
INNER JOIN {bq_project}.{bq_dataset}.ad_matching AS AM
  ON AP.ad_id = AM.ad_id
LEFT JOIN {bq_project}.{bq_dataset}.media AS Media
    ON AM.youtube_video_id = Media.youtube_video_id
GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15);
