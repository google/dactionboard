SELECT
    segments.date AS date,
    segments.ad_network_type AS network,
    campaign.id as campaign_id,
    ad_group.id AS ad_group_id,
    ad_group_ad.ad.id AS ad_id,
    asset.id AS asset_id,
    metrics.clicks AS clicks,
    metrics.impressions AS impressions,
    metrics.cost_micros AS cost,
    metrics.biddable_app_install_conversions AS installs,
    metrics.biddable_app_post_install_conversions AS inapps,
    metrics.all_conversions  AS all_conversions,
    metrics.conversions  AS conversions,
    metrics.view_through_conversions  AS view_through_conversions,
    metrics.conversions_value AS conversion_value
FROM ad_group_ad_asset_view
WHERE
    segments.date >= "{start_date}"
    AND segments.date <= "{end_date}"
    AND ad_group_ad_asset_view.field_type = "YOUTUBE_VIDEO"
