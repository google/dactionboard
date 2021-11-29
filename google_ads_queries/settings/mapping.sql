SELECT
    customer.descriptive_name AS account_name,
    customer.id AS account_id,
    campaign.id AS campaign_id,
    campaign.name AS campaign_name,
    campaign.status AS campaign_status
FROM
    campaign
