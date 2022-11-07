SELECT
    ad_group_ad.ad.id AS ad_id,
    ad_group_ad.ad.type AS ad_type,
    ad_group_ad.ad.final_urls AS final_urls,
    ad_group_ad.ad.video_responsive_ad.companion_banners AS responsive_companion_banner,
    ad_group_ad.ad.video_responsive_ad.headlines AS headlines,
    ad_group_ad.ad.video_responsive_ad.long_headlines AS long_headlines,
    ad_group_ad.ad.video_responsive_ad.descriptions AS descriptions,
    ad_group_ad.ad.video_responsive_ad.videos AS videos,
    ad_group_ad.ad.video_responsive_ad.call_to_actions AS call_to_actions,
    ad_group_ad.ad.video_ad.in_stream.action_button_label AS action_button_label,
    ad_group_ad.ad.video_ad.in_stream.companion_banner.asset AS in_stream_companion_banner
FROM ad_group_ad
WHERE
    ad_group_ad.ad.type IN (
        "VIDEO_RESPONSIVE_AD",
        "VIDEO_TRUEVIEW_IN_STREAM_AD"
    )
    AND campaign.bidding_strategy_type IN (
        "MAXIMIZE_CONVERSIONS",
        "TARGET_CPA"
    )