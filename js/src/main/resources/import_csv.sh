#!/usr/bin/env bash

cat "mockdata/tables.sql" | sqlite3 tiw.db
sqlite3 -separator ',' tiw.db ".import -skip 1 mockdata/user.csv user"
sqlite3 -separator ',' tiw.db ".import -skip 1 mockdata/track.csv track"
sqlite3 -separator ',' tiw.db ".import -skip 1 mockdata/playlist.csv playlist"
sqlite3 -separator ',' tiw.db ".import -skip 1 mockdata/playlist_tracks.csv playlist_tracks"
