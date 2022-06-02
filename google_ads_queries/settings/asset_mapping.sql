SELECT
    asset.id AS asset_id,
    asset.name AS asset_name,
    asset.image_asset.full_size.url AS url,
    asset.youtube_video_asset.youtube_video_id AS youtube_video_id,
    asset.youtube_video_asset.youtube_video_title AS youtube_title
FROM asset
WHERE asset.type IN (
    "IMAGE",
    "YOUTUBE_VIDEO"
)

