SELECT
    campaign.id AS campaign_id,
    ad_group.id AS ad_group_id,
    ad_group_extension_setting.extension_feed_items AS sitelinks 
FROM
   ad_group_extension_setting
WHERE
    ad_group_extension_setting.extension_type = "SITELINK"
