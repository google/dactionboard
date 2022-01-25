SELECT
    segments.date AS date,
    ad_group.id AS ad_group_id,
    ad_group.type AS ad_group_type,
    ad_group_criterion.age_range.type AS age_range,
    metrics.clicks AS clicks,
    metrics.impressions AS impressions,
    metrics.cost_micros AS cost,
    metrics.conversions AS conversions,
    metrics.all_conversions AS all_conversions,
    metrics.view_through_conversions AS view_through_conversions,
    metrics.video_views AS video_views,
    metrics.interactions AS engagements
FROM age_range_view
WHERE
    segments.date >= "{start_date}"
    AND segments.date <= "{end_date}"
    AND ad_group.type IN (
	"VIDEO_RESPONSIVE",
	"VIDEO_TRUE_VIEW_IN_DISPLAY",
	"VIDEO_TRUE_VIEW_IN_STREAM"
	)
    AND campaign.bidding_strategy_type IN (
	"MAXIMIZE_CONVERSIONS",
	"TARGET_CPA"
    )
