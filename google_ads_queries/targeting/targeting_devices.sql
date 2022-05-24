SELECT
    campaign.id AS campaign_id,
    campaign_criterion.display_name AS device_type
FROM campaign_criterion
WHERE
    campaign_criterion.type IN (
        "DEVICE",
        "MOBILE_DEVICE"
    )
    AND campaign_criterion.status = "ENABLED"
    AND campaign_criterion.negative = FALSE
