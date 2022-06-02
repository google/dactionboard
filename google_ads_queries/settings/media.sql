SELECT
  media_file.id AS id,
  media_file.video.youtube_video_id AS youtube_video_id,
  media_file.video.ad_duration_millis AS youtube_video_duration
FROM media_file
WHERE media_file.type = "VIDEO"
