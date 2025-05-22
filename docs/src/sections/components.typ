#import "../lib.typ":*

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
  - UploadTrack
  - #ria() GetTracksNotInPlaylist
  - #ria() TrackReorder
  - #ria() GetUserTracks

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
- getTrackGroup
- addTracksToPlaylist
- removeTracksFromPlaylist
- checkPlaylistOwner
- getUserPlaylists
- getPlaylistTracksByTitle
- createPlaylist
- getPlaylistTracksById#footnote[Modified in the RIA version to account for custom track order.]
- getTracksNotInPlaylist
- #ria() updateTrackOrder

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

== RIA subproject



#show: table-styles.with()

#figure(
  placement: top,
  scope: "parent",
  table(
    columns: 4,
    align: horizon,
    table.header(
      table.cell(colspan: 2)[Client side],
      table.cell(colspan: 2)[Server side],
      [Event], [Action],
      [Event], [Action],
    ),
    [Index $=>$ Login form $=>$ Submit], [Data validation], [POST (`username`, `password`)], [Credentials check],
    [HomePage $=>$ Load], [Loads all User playlists], [GET (`user playlists`)], [Queries user playlists],
    [HomePage $=>$ Click on a playlist], [Loads all tracks associated to that Playlist], [GET (`playlistId`)], [Queries the tracks associated to the given playlistId],
    [HomePage $=>$ Click on reorder button], [Load a modal to custom order the track in the Playlist], [GET (`playlistId`)], [Queries the tracks associated to the given playlistId],
    [Reorder modal $=>$ Save order button], [Saves the custom order to the database], [POST (`trackIds, playlistId`)], [Updates the `playlist_tracks` table with the new custom order],
    [Create playlist modal $=>$ Create playlist button], [Loads the modal to create a new playlist; returns the newly created playlist if successful], [POST (`playlistTitle`, `selectedTracks`)], [Inserts the new Playlist in the `playlist` table],
    [Upload track modal $=>$ Upload track button], [Loads the modal to upload a new track; returns the newly uploaded track if successful], [POST (`title`, `artist`, `year`, `album`, `genre`, `image`, `musicTrack`)], [Inserts the new Track in the `tracks` table],
    [Sidebar $=>$ Playlist button], [Views the last selected Playlist, if one had been selected], [GET (`last selected Playlist`)], [Queries the tracks associated to the given playlistId],
    [Sidebar $=>$ Track button], [Views the last selected Track, if one had been selected], [GET (`last selected Track`)], [Queries the data associated with the given trackId],
    [Sidebar $=>$ HomePage], [Returns to the HomePage], [GET (user playlists)], [Queries user playlists],
    [Logout], [Invalidates the current User session], [GET], [Session invalidation],
  ),
  caption: [Events & Actions.]
)

#figure(
  placement: top,
  scope: "parent",
  table(
    columns: 4,
    align: horizon,
    table.header(
      table.cell(colspan: 2)[Client side],
      table.cell(colspan: 2)[Server side],
      [Event], [Controller],
      [Event], [Controller]
    ),
    [Index $=>$ Login form $=>$ Submit], [`makeCall()` function], [POST (`username`, `password`)], [Login (servlet)],
    [HomePage $=>$ Load], [`HomePage.show()` function (its invocation is done by the PageOrchestrator function)], [GET], [Homepage (servlet)],
    [HomePage $=>$ Click on a playlist], [Loads all tracks associated to that Playlist], [GET (`playlistId`)], [Playlist (servlet)],
    [HomePage $=>$ Click on reorder button], [Load a modal to custom order the track in the Playlist], [GET (`playlistId`)], [Playlist (servlet)],
    [Reorder modal $=>$ Save order button], [Saves the custom order to the database], [POST (`trackIds`, `playlistId`)], [TrackReorder (servlet)],
    [Create playlist modal $=>$ Create playlist button], [Loads the modal to create a new playlist; returns the newly created playlist if successful], [POST (`playlistTitle`, `selectedTracks`)], [CreateNewPlaylist (servlet)],
    [Upload track modal $=>$ Upload track button], [Loads the modal to upload a new track; returns the newly uploaded track if successful], [POST (`title`, `artist`, `year`, `album`, `genre`, `image`, `musicTrack`)], [UploadTrack (servlet)],
    [Sidebar $=>$ Playlist button], [Views the last selected Playlist, if one had been selected], [GET (`last selected Playlist`)], [Playlist (servlet)],
    [Sidebar $=>$ Track button], [Views the last selected Track, if one had been selected], [GET (`last selected Track`)], [Track (servlet)],
    [Sidebar $=>$ HomePage], [Returns to the HomePage], [GET (`user playlists`)], [Homepage (servlet)],
    [Logout], [`makeCall()` function], [GET], [Logout (servlet)],
  ),
  caption: [Events & Controllers (or event handlers).]
)
