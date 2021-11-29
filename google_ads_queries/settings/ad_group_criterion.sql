SELECT
    customer.id AS customer_id,
    campaign.id AS campaign_id,
    ad_group.id AS ad_group_id,
    ad_group.explorer_auto_optimizer_setting.opt_in AS is_auto_targeting,
    ad_group_criterion.criterion_id AS criterion_id,
    ad_group_criterion.negative AS is_negative,
    ad_group_criterion.custom_audience.custom_audience AS custom_audience,
    ad_group_criterion.custom_intent.custom_intent AS custom_intent,
    ad_group_criterion.display_name AS display_name,
    ad_group_criterion.type AS type,
    user_interest.name AS user_interest,
    user_list.name AS user_list
FROM ad_group_criterion
WHERE
    ad_group_criterion.type IN (
	"CUSTOM_AUDIENCE",
	"USER_LIST"
    )
    AND ad_group_criterion.status = "ENABLED"
    AND ad_group_criterion.negative = FALSE
