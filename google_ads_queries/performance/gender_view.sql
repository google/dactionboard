SELECT
    segments.date AS date,
    ad_group.id AS ad_group_id,
    ad_group.type AS ad_group_type,
    ad_group_criterion.gender.type AS gender_type,
    metrics.clicks AS clicks,
    metrics.impressions AS impressions,
    metrics.cost_micros AS cost,
    metrics.conversions AS conversions,
    metrics.all_conversions AS all_conversions,
    metrics.view_through_conversions AS view_through_conversions,
    metrics.video_views AS video_views,
    metrics.engagements AS engagements
FROM gender_view
WHERE
    segments.date >= "{start_date}"
    AND segments.date <= "{end_date}"
    AND campaign.advertising_channel_sub_type = "VIDEO_ACTION"
    AND campaign.bidding_strategy_type IN (
        "MAXIMIZE_CONVERSIONS",
        "TARGET_CPA"
    )
