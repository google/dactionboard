SELECT
    conversion_action.id AS conversion_id,
    conversion_action.include_in_conversions_metric AS include_in_conversions,
    conversion_action.name AS name,
    conversion_action.status AS status,
    conversion_action.type AS type,
    conversion_action.category AS category
FROM conversion_action
