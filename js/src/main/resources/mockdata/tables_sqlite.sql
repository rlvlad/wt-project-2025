DROP TABLE IF EXISTS user;
DROP TABLE IF EXISTS track;
DROP TABLE IF EXISTS playlist;
DROP TABLE IF EXISTS playlist_tracks;

-- TABLE CREATION

CREATE TABLE user
(
    user_id  integer primary key autoincrement,
    nickname varchar(32) not null unique,
    password varchar(64) not null,
    name     varchar(32) not null,
    surname  varchar(32) not null
);

CREATE TABLE track
(
    track_id       integer primary key autoincrement,
    user_id        integer       not null,
    title          varchar(128)  not null,
    album_title    varchar(128)  not null,
    artist         varchar(64)   not null,
    year           year          not null,
    genre          varchar(64),
    song_checksum  char(64)      not null default '0000000000000000000000000000000000000000000000000000000000000000',
    image_checksum char(64)      not null default '0000000000000000000000000000000000000000000000000000000000000000',
    song_path      varchar(1024) not null,
    image_path     varchar(1024) not null,

    foreign key (user_id) references user (user_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    unique (user_id, song_checksum),
    unique (user_id, title, artist),
    check (genre in
           ('Classical', 'Rock', 'Edm', 'Pop', 'Hip-hop', 'R&B', 'Country', 'Jazz', 'Blues', 'Metal', 'Folk', 'Soul',
            'Funk', 'Electronic', 'Indie', 'Reggae', 'Disco'))
);

CREATE TABLE playlist
(
    playlist_id    integer     primary key autoincrement,
    playlist_title varchar(32) not null,
    creation_date  date        not null default CURRENT_DATE,
    user_id        integer     not null,

    unique (playlist_title, user_id),
    foreign key (user_id) references user (user_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE playlist_tracks
(
    playlist_id  integer not null,
    track_id     integer not null,
    custom_order integer,

    primary key (playlist_id, track_id),
    foreign key (playlist_id) references playlist (playlist_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    foreign key (track_id) references track (track_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);
