SELECT
    campaign.id AS campaign_id,
    campaign.name AS campaign_name,
    campaign.status AS campaign_status,
    campaign.advertising_channel_sub_type AS campaign_sub_type,
    campaign.bidding_strategy_type AS bidding_strategy,
    ad_group.name AS ad_group_name,
    ad_group_ad.ad.id AS ad_id,
    ad_group_ad.ad.name AS ad_name,
    video.id AS youtube_video_id,
    video.title AS youtube_title
FROM video
WHERE
    campaign.advertising_channel_sub_type = "VIDEO_ACTION"
    AND campaign.bidding_strategy_type IN (
        "MAXIMIZE_CONVERSIONS",
        "TARGET_CPA"
    )
