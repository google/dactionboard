SELECT
    campaign.id AS campaign_id,
    campaign.name AS campaign_name,
    campaign.status AS status,
    campaign.start_date AS start_date,
    campaign.end_date AS end_date,
    campaign.bidding_strategy_type AS bidding_strategy,
    campaign_budget.amount_micros AS budget_amount,
    campaign_budget.total_amount_micros AS total_budget,
    campaign_budget.type AS budget_type,
    campaign_budget.explicitly_shared AS is_shared_budget,
    campaign_budget.period AS budget_period,
    campaign.target_cpa.target_cpa_micros AS target_cpa,
    campaign.target_roas.target_roas AS target_roas,
    campaign.maximize_conversions.target_cpa AS max_conv_target_cpa,
    metrics.cost_micros AS cost,
    metrics.conversions AS conversions
FROM campaign
WHERE campaign.advertising_channel_type = "VIDEO"
    AND segments.date >= "{start_date}"
    AND segments.date <= "{end_date}"
    AND metrics.impressions >= 0
