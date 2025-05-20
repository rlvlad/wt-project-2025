= Codebase overview

== Components

The projects is composed of the following components:

+ DAOs
  - PlaylistDAO
  - TrackDAO
  - UserDAO
  - DAO interface

The DAO interface has only the default method `close()`, which is used in nearly all DAOs -- this way we are able to follow the DRY principle (#emph[Don't Repeat Yourself]).

2. Entities
  - Playlist
  - Track
  - User

Unlike most WT projects, these are record classes @record-classes: basically they are built-in old-school beans. We opted their use to drastically reduce boilerplate and simplify the codebase.

3. Servlets
  - Login
  - HomePage
  - Playlist
  - Register
  - Track
  - Logout
  - AddTracks
  - CreatePlaylist
  - [RIA] TrackReordering

+ Filters
  - UserChecker
  - InvalidUserChecker
  - TrackChecker
  - SelectedTracksChecker
  - PlaylistChecker

+ Utils (short-term for Utilities)
  - ConnectionHandler
  - TemplateEngineHandler

As per the DAO interface, the same idea has been applied to the `ConnectionHandler` and `TemplateEngineHandler` classes.

// which hold the otherwise repeated code in `init()` methods across the project.

// #colbreak()

== DAOs methods

PlaylistDAO methods:

- getPlaylistTitle
- deletePlaylist
- getTrackGroup#footnote[Modified in the RIA version to account for custom track order.]
- addTracksToPlaylist
- removeTracksFromPlaylist
- checkPlaylistOwner
- getUserPlaylists
- getPlaylistTracksByTitle
- createPlaylist
- getPlaylistTracksById
- [RIA] getTracksNotInPlaylist
- [RIA] updateTrackOrder

TrackDAO methods:

- addTrack
- isImageFileAlreadyPresent
- checkTrackOwner
- isTrackFileAlreadyPresent
- getTrackById
- getUserTracks

UserDAO methods:

- checkUser
- addUser

All the methods are intuitively named and don't need further explanations. Either way, they are explained throughout the next section in their respective sequence.
