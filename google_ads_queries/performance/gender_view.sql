SELECT
    segments.date AS date,
    ad_group.id AS ad_group_id,
    ad_group_criterion.gender.type AS age_range_type,
    gender_view.resource_name~1 AS gender_criterion_id,
    metrics.clicks AS clicks,
    metrics.impressions AS impressions,
    metrics.cost_micros AS cost,
    metrics.conversions AS conversions,
    metrics.all_conversions AS all_conversions,
    metrics.video_views AS video_views,
    metrics.engagements AS engagements
FROM gender_view
WHERE
    segments.date >= "{start_date}"
    AND segments.date <= "{end_date}"
