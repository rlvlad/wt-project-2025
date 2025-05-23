#import "../lib.typ" : *

= SQL database schema<sql-database-schema>

== Overview

The project requirements slightly change from `pure_html` and `js`, where the latter requires the tracks to support an individual custom order within the playlist to which they are associated -- this is achieved via a simple addition in the SQL tables schema.

In both scenarios, the schema is composed by four tables: `user`, `track`, `playlist` and `playlist_tracks`.

#figure(
  image("../img/uml/uml_bluetto.png"),
  caption: [UML diagram.],
)<uml-diagram>

== The tables

- `user` table
```sql
CREATE TABLE user
(
    user_id  integer     not null auto_increment,
    nickname varchar(32) not null unique,
    password varchar(64) not null,
    name     varchar(32) not null,
    surname  varchar(32) not null,

    primary key (user_id)
);
```
it is quite staightforward and standard. Apart from the `user_id` attribute, which is the primary key, the only other attribute that has a unique constraint is `nickname`. It couldn't be a multiple primary key because in that case there could have been multiple users with the same nickname, which isn't our goal.

- `track` table
```sql
CREATE TABLE track
(
    track_id       integer       not null auto_increment,
    user_id        integer       not null,
    title          varchar(128)  not null,
    album_title    varchar(128)  not null,
    artist         varchar(64)   not null,
    year           year          not null,
    genre          varchar(64),
    song_checksum  char(64)      not null default '0...0',
    image_checksum char(64)      not null default '0...0',
    song_path      varchar(1024) not null,
    image_path     varchar(1024) not null,

    primary key (track_id),
    foreign key (user_id) REFERENCES user (user_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    unique (user_id, song_checksum),
    unique (user_id, title, artist),
    check (genre in ('Classical', 'Rock', 'Edm', 'Pop', 'Hip-hop', 'R&B', 'Country', 'Jazz', 'Blues', 'Metal', 'Folk', 'Soul', 'Funk', 'Electronic', 'Indie', 'Reggae', 'Disco'))
);
```
this needs to be addressed since we implemented a special feature, which is the checksum for the song and the album image. As their name implies, they are the SHA256 checksum of the song and image: their purpose is to let the server store only one copy of the same file, which couldn't have been properly achieved by checking only the filename.

Next, the other attributes are pretty standard. As per the `user` table, there is the unique constraint on `user_id, song_checksum` to account for what is written above; while `user_id, title, artist` does the same job though internally in the database#footnote[A User can't have duplicate tracks.]. Finally, a track is strictly bound to a user: that's the the foreign key is for.

- `playlist` table
```sql
CREATE TABLE playlist
(
    playlist_id    integer     not null auto_increment,
    playlist_title varchar(32) not null,
    creation_date  date        not null default CURRENT_DATE,
    user_id        integer     not null,

    primary key (playlist_id),
    unique (playlist_title, user_id),
    foreign key (user_id) REFERENCES user (user_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);
```
once again this table is rather standard. The `creatione_date` attribute defaults to the today's date; and again there is the unique constraint on `playlist_title, user_id` because a playlist is bound to a single User (who can't have duplicate playlists -- that is with the same title) via the foreign key.


- `playlist_tracks` table
```sql
CREATE TABLE playlist_tracks
(
    playlist_id  integer not null,
    track_id     integer not null,

    primary key (playlist_id, track_id),
    foreign key (playlist_id) REFERENCES playlist (playlist_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    foreign key (track_id) REFERENCES track (track_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);
```<playlist-tracks-code>
this table represents the "Contained in" relation in the ER diagram (@er-diagram). Its primary key is multiple (the only one in the project) and has to link a track to a playlist -- unlike the other tables, which _explicitly needed_ a primary key _and_ a unique constraint, in this case a composite key it's correct because a track can appear in multiple playlists.

- #ria() `playlist_tracks` table in RIA project
```sql
CREATE TABLE playlist_tracks
(
    playlist_track_id integer auto_increment,
    playlist_id       integer not null,
    track_id          integer not null,
    custom_order      integer,

    primary key (playlist_track_id),
    unique (playlist_id, track_id),
    foreign key (playlist_id) references playlist (playlist_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    foreign key (track_id) references track (track_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);
```<playlist-tracks-code>
similarly to the previous code, this one too is the translation of the "Contained in" relation in the _RIA_ ER diagram (@er-diagram-ria), with the added `custom_order` attribute. The previous primary key has been converted to unique -- similarly to other parts in the project -- and the rest is unvaried.
