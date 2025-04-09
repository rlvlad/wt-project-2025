SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS user CASCADE;
DROP TABLE IF EXISTS track CASCADE;
DROP TABLE IF EXISTS user_tracks CASCADE;
DROP TABLE IF EXISTS playlist CASCADE;
DROP TABLE IF EXISTS playlist_tracks CASCADE;

SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE user
(
    nickname varchar(32) unique not null,
    password varchar(64)        not null,
    name     varchar(32)        not null,
    surname  varchar(32)        not null,

    primary key (nickname)
);

CREATE TABLE track
(
    track_id    integer      not null,
    title       varchar(16)  not null,
    image_path  varchar(128) not null,
    album_title varchar(16)  not null,
    artist      varchar(16)  not null,
    year        year         not null,
    genre       varchar(16),
    path        varchar(16),

    primary key (track_id),
    check (genre in ('classical', 'rock', 'edm'))
);

CREATE TABLE user_tracks
(
    nickname varchar(32) not null,
    track_id integer     not null,

    primary key (nickname, track_id),
    foreign key (nickname) references user (nickname),
    foreign key (track_id) references track (track_id)
);

CREATE TABLE playlist
(
    playlist_id    integer     not null,
    playlist_title varchar(16) not null,
    creation_date  date        not null,
    nickname       varchar(32) not null,

    primary key (playlist_id),
    foreign key (nickname) references user (nickname)
);

CREATE TABLE playlist_tracks
(
    playlist_id  integer not null,
    track_id     integer not null,
    custom_order integer,

    primary key (playlist_id, track_id),
    foreign key (playlist_id) references playlist (playlist_id),
    foreign key (track_id) references track (track_id)
);
