SELECT
    customer.id AS customer_id,
    customer.descriptive_name AS account_name,
    customer.currency_code AS currency_code,
    customer.conversion_tracking_setting.conversion_tracking_id AS conversion_tracking_id
FROM
    customer
