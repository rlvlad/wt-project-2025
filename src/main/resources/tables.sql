SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS user CASCADE;
DROP TABLE IF EXISTS track CASCADE;
DROP TABLE IF EXISTS user_tracks CASCADE;
DROP TABLE IF EXISTS playlist CASCADE;

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
    title       varchar(16)  not null,
    image_path  varchar(128) not null,
    album_title varchar(16)  not null,
    artist      varchar(16)  not null,
    year        year         not null,
    genre       varchar(16),
    path        varchar(16),

    primary key (title, artist),
    check (genre in ('classical', 'rock', 'edm'))
);

CREATE TABLE user_tracks
(
    nickname varchar(32) not null,
    title    varchar(16) not null,
    artist   varchar(16) not null,

    primary key (nickname, title, artist),
    foreign key (nickname) references user (nickname),
    foreign key (title, artist) references track (title, artist)
);

CREATE TABLE playlist
(
    id             integer auto_increment,
    playlist_title varchar(16) not null,
    title          varchar(16) not null,
    artist         varchar(16) not null,
    track_order    integer,

    primary key (id, title, artist),
    foreign key (title, artist) references user_tracks (title, artist)
);
