SELECT
    campaign.id AS campaign_id,
    campaign_criterion.location.geo_target_constant AS location
FROM campaign_criterion
WHERE
    campaign_criterion.type IN (
        "LOCATION"
    )
    AND campaign_criterion.status = "ENABLED"
    AND campaign_criterion.negative = FALSE
