SELECT
    segments.date AS date,
    campaign.id AS campaign_id,
    campaign.bidding_strategy_type AS bidding_strategy_type,
    ad_group.id AS ad_group_id,
    ad_group_ad.ad.id AS ad_id,
    segments.device AS device,
    metrics.clicks AS clicks,
    metrics.impressions AS impressions,
    metrics.cost_micros AS cost,
    metrics.conversions AS conversions,
    metrics.all_conversions AS all_conversions,
    metrics.view_through_conversions AS view_through_conversions,
    metrics.video_views AS video_views,
    metrics.engagements AS engagements
FROM ad_group_ad
WHERE
    segments.date >= "{start_date}"
    AND segments.date <= "{end_date}"
    AND campaign.advertising_channel_sub_type = "VIDEO_ACTION"
    AND campaign.bidding_strategy_type IN (
        "MAXIMIZE_CONVERSIONS",
        "TARGET_CPA"
    )
