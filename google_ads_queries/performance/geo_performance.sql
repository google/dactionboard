SELECT
    segments.date AS date,
    user_location_view.country_criterion_id AS country_criterion_id,
    segments.geo_target_city AS city,
    ad_group.id AS ad_group_id,
    metrics.clicks AS clicks,
    metrics.impressions AS impressions,
    metrics.cost_micros AS cost,
    metrics.conversions AS conversions,
    metrics.all_conversions AS all_conversions,
    metrics.video_views AS video_views,
    metrics.interactions AS engagements
FROM user_location_view
WHERE
    segments.date >= "{start_date}"
    AND segments.date <= "{end_date}"
