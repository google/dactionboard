SELECT
    segments.date AS date,
    campaign.id AS campaign_id,
    ad_group.id AS ad_group_id,
    ad_group_ad.ad.id AS ad_id,
    segments.device AS device,
    metrics.clicks AS clicks,
    metrics.impressions AS impressions,
    metrics.cost_micros AS cost,
    metrics.conversions AS conversions,
    metrics.all_conversions AS all_conversions,
    metrics.video_views AS video_views,
    metrics.engagements AS engagements
FROM ad_group_ad
WHERE metrics.impressions >= 0
    AND segments.date >= "{start_date}"
    AND segments.date <= "{end_date}"
    AND ad_group_ad.ad.type IN (
	"VIDEO_AD",
	"VIDEO_RESPONSIVE_AD",
	"VIDEO_BUMPER_AD",
	"VIDEO_NON_SKIPPABLE_IN_STREAM_AD",
	"VIDEO_OUTSTREAM_AD",
	"VIDEO_RESPONSIVE_AD",
	"VIDEO_TRUEVIEW_DISCOVERY_AD",
	"VIDEO_TRUEVIEW_IN_STREAM_AD"
	)
    AND campaign.bidding_strategy_type IN (
	"MAXIMIZE_CONVERSIONS",
	"TARGET_CPA"
    )
