SELECT
    ad_group.id AS ad_group,
    ad_group_extension_setting.extension_feed_items AS feed_items
FROM
   ad_group_extension_setting
WHERE
    ad_group_extension_setting.extension_type = "SITELINK"
