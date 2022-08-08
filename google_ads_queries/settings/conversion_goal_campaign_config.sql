SELECT
    campaign.id AS campaign_id,
    custom_conversion_goal.conversion_actions AS actions
FROM conversion_goal_campaign_config
WHERE campaign.advertising_channel_type = "VIDEO"
    AND campaign.bidding_strategy_type IN (
        "MAXIMIZE_CONVERSIONS",
        "TARGET_CPA"
    )
