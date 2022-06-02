SELECT
    segments.date AS date,
    user_location_view.country_criterion_id AS country_criterion_id,
    campaign.advertising_channel_sub_type AS campaign_sub_type,
    campaign.bidding_strategy_type AS bidding_strategy_type,
    ad_group.id AS ad_group_id,
    ad_group.type AS ad_group_type,
    metrics.clicks AS clicks,
    metrics.impressions AS impressions,
    metrics.cost_micros AS cost,
    metrics.conversions AS conversions,
    metrics.all_conversions AS all_conversions,
    metrics.view_through_conversions AS view_through_conversions,
    metrics.video_views AS video_views,
    metrics.interactions AS engagements
FROM user_location_view
WHERE
    segments.date >= "{start_date}"
    AND segments.date <= "{end_date}"
    AND campaign.advertising_channel_sub_type = "VIDEO_ACTION"
    AND campaign.bidding_strategy_type IN (
        "MAXIMIZE_CONVERSIONS",
        "TARGET_CPA"
    )
