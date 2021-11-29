SELECT
    segments.date AS date,
    ad_group.id AS ad_group_id,
    age_range_view.resource_name~1 AS age_criterion_id,
    metrics.clicks AS clicks,
    metrics.impressions AS impressions,
    metrics.cost_micros AS cost,
    metrics.conversions AS conversions,
    metrics.all_conversions AS all_conversions,
    metrics.video_views AS video_views,
    metrics.interactions AS engagements
FROM age_range_view
WHERE
    segments.date >= "{start_date}"
    AND segments.date <= "{end_date}"
