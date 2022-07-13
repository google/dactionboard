CREATE OR REPLACE TABLE {bq_project}.{bq_dataset}.video_conversion_split_F
AS (
WITH PerformanceTable AS (
    SELECT
        date,
        ad_group_id,
        ad_id,
        SUM(cost) AS cost
    FROM {bq_project}.{bq_dataset}.ad_performance
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
    M.ad_group_id,
    M.ad_group_name,
    M.ad_group_status,
    AP.ad_id,
    AM.youtube_video_id,
    AM.youtube_title AS video_title,
    ROUND(AM.youtube_video_duration / 1000) AS video_duration,
    AP.conversion_name,
    SUM(P.cost / 1e6) AS cost,
    SUM(AP.all_conversions) AS all_conversions,
    SUM(AP.conversions) AS conversions,
    SUM(AP.view_through_conversions) AS view_through_conversions
FROM {bq_project}.{bq_dataset}.conversion_split AS AP
INNER JOIN PerformanceTable AS P
    USING(ad_group_id, date, ad_id)
INNER JOIN {bq_project}.{bq_dataset}.mapping AS M
  ON AP.ad_group_id = M.ad_group_id
INNER JOIN {bq_project}.{bq_dataset}.ad_matching AS AM
  ON AP.ad_id = AM.ad_id
GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15);
