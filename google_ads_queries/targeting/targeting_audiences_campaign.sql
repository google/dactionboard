SELECT
    campaign.id AS campaign_id,
    campaign_criterion.type AS type,
    user_interest.taxonomy_type AS user_interest_type,
    user_interest.name AS user_interest_name,
    campaign_criterion.display_name AS display_name
FROM campaign_criterion
WHERE
    campaign_criterion.type IN (
        "COMBINED_AUDIENCE",
        "CUSTOM_AUDIENCE",
        "CUSTOM_AFFINITY",
        "CUSTOM_INTENT",
        "USER_LIST",
        "USER_INTEREST"
    )
    AND campaign_criterion.status = "ENABLED"
    AND campaign_criterion.negative = FALSE
