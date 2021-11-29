SELECT
    customer.id AS customer_id,
    campaign.id AS campaign_id,
    campaign_criterion.custom_audience.custom_audience AS custom_audience,
    campaign_criterion.display_name AS display_name,
    campaign_criterion.type AS type,
    user_interest.name AS user_interest,
    user_list.name AS user_list
FROM campaign_criterion
WHERE
    campaign_criterion.type IN (
	"CUSTOM_AUDIENCE",
	"USER_LIST"
    )
    AND campaign_criterion.status = "ENABLED"
    AND campaign_criterion.negative = FALSE
