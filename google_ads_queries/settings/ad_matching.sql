SELECT
    campaign.id AS campaign_id,
    campaign.name AS campaign_name,
    campaign.bidding_strategy_type AS bidding_strategy,
    ad_group.name AS ad_group_name,
    ad_group_ad.ad.id AS ad_id,
    ad_group_ad.ad.type AS ad_group_ad_type,
    ad_group_ad.ad.name AS ad_name,
    video.id AS youtube_video_id,
    video.title AS youtube_title,
    video.duration_millis AS youtube_video_duration
FROM video
WHERE ad_group_ad.ad.type IN (
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
