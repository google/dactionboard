SELECT
    ad_group.id AS ad_group_id,
    ad_group_criterion.type AS type,
    user_interest.taxonomy_type AS user_interest_type,
    user_interest.name AS user_interest_name,
    ad_group_criterion.display_name AS display_name
FROM ad_group_criterion
WHERE
    ad_group_criterion.type IN (
        "COMBINED_AUDIENCE",
        "CUSTOM_AUDIENCE",
        "CUSTOM_AFFINITY",
        "CUSTOM_INTENT",
        "USER_LIST",
        "USER_INTEREST"
    )
    AND ad_group_criterion.status = "ENABLED"
    AND ad_group_criterion.negative = FALSE
