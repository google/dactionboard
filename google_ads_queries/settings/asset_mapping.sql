SELECT
    asset.id AS asset_id,
    asset.name AS asset_name,
    asset.image_asset.full_size.url AS url
FROM asset
WHERE asset.type = "IMAGE"

