SELECT
    customer.descriptive_name AS account_name,
    customer.currency_code AS currency,
    customer.id AS account_id,
    campaign.id AS campaign_id,
    campaign.bidding_strategy_type AS bidding_strategy,
    campaign.name AS campaign_name,
    campaign.status AS campaign_status,
    ad_group.id AS ad_group_id,
    ad_group.name AS ad_group_name,
    ad_group.status AS ad_group_status
FROM
    ad_group
WHERE
    ad_group.type IN (
        "VIDEO_RESPONSIVE",
        "VIDEO_TRUE_VIEW_IN_DISPLAY",
        "VIDEO_TRUE_VIEW_IN_STREAM"
    )
    AND campaign.bidding_strategy_type IN (
        "MAXIMIZE_CONVERSIONS",
        "TARGET_CPA"
    )
