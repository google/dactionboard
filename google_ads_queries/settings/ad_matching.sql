SELECT
    campaign.id AS campaign_id,
    campaign.name AS campaign_name,
    ad_group.name AS ad_group_name,
    ad_group_ad.ad.id AS ad_id,
    ad_group_ad.ad.name AS ad_name,
    video.id AS youtube_video_id,
    video.title AS youtube_title,
    video.duration_millis AS youtube_video_duration
FROM video
