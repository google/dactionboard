SELECT
    campaign.id AS ad_group_id,
    ad_group_criterion.topic.path AS topic
FROM ad_group_criterion
WHERE
    ad_group_criterion.type IN (
        "TOPIC"
    )
    AND ad_group_criterion.status = "ENABLED"
    AND ad_group_criterion.negative = FALSE
