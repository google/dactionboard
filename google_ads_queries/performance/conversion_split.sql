SELECT
    segments.date AS date,
    ad_group.id AS ad_group_id,
    ad_group_ad.ad.id AS ad_id,
    segments.conversion_action AS conversion_action,
    segments.conversion_action_name AS conversion_name,
    metrics.conversions AS conversions,
    metrics.all_conversions AS all_conversions,
    metrics.view_through_conversions AS view_through_conversions
FROM ad_group_ad
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
