########################
# CHECKS
########################

# check if the user exists
SELECT nickname, password
FROM user
WHERE nickname = 'user'
  AND password = 'password'
;

# check if the track exists
SELECT title, image_path, album_title, artist, year, genre, path
FROM track
WHERE title = 'title'
  and image_path = 'image_path'
  and album_title = 'album_title'
  and artist = 'artist'
  and year = 'year'
  and genre = 'genre'
  and path = 'path'
;

# check if the playlist exists
SELECT playlist_title, creation_date
FROM playlist
WHERE nickname = 'user'
  AND playlist_title = 'playlist_title'
;

########################
# DATA RETRIEVAL
#########################

# get all user's track
SELECT title, image_path, album_title, artist, year, genre, path
FROM user a
         NATURAL JOIN user_tracks b
         NATURAL JOIN track c
WHERE nickname = 'user'
;

# get all user's playlists
SELECT playlist_title, creation_date
FROM user a
         NATURAL JOIN playlist b
WHERE nickname = 'user'
;

# get all tracks in a playlist
SELECT title, image_path, album_title, artist, year, genre, path
FROM user a
         NATURAL JOIN playlist b
         NATURAL JOIN track c
WHERE nickname = 'user'
  AND playlist_title = 'playlist_title'
;

########################
# DATA ADDING
########################

# add a user
INSERT INTO user(nickname, password, name, surname)
VALUES ('nickname', 'password', 'name', 'surname')
;

# add a track
# // TODO

# add a playlist
# // TODO

########################
# DATA REMOVAL
########################

# delete a user (=> deletes associated user_tracks, playlists & playlist_tracks)
DELETE
FROM user
WHERE nickname = 'user'
;

# delete a playlist
DELETE
FROM playlist
WHERE playlist_title = 'playlist_title'
  AND nickname = 'nickname'
;

# delete a track (=> delete associated user_tracks)
DELETE
FROM track
WHERE title = 'title'
  and image_path = 'image_path'
  and album_title = 'album_title'
  and artist = 'artist'
  and year = 'year'
  and genre = 'genre'
  and path = 'path'
;

# delete a user track
DELETE
FROM user_tracks
WHERE nickname = 'user'
  AND track_id = 'track_id'
;

########################
# DATA UPDATING
########################

# update user nickname
# trigger to check if the nickname is already taken or not
UPDATE user
SET nickname = 'new_nickname'
WHERE nickname = 'old_nickname'
;

# update playlist name
# // TODO
