SELECT
    campaign.id AS campaign_id,
    campaign_extension_setting.extension_feed_items AS feed_items
FROM
   campaign_extension_setting
WHERE
    campaign_extension_setting.extension_type = "SITELINK"
