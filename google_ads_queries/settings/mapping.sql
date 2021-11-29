SELECT
    customer.id AS customer_id,
    campaign.id AS campaign_id,
    campaign.name AS campaign_name,
    campaign.status AS campaign_status,
    ad_group.id AS ad_group_id,
    ad_group.name AS ad_group_name,
    ad_group.status AS ad_group_status
FROM
    ad_group
