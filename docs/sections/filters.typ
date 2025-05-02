#import "../lib.typ": *

= Filter mappings

#double_col_spaces(1cm)

#seq_diagram(
  "UserChecker",
  diagram({
    _par("A", display-name: "Client")
    _par("B", display-name: "UserChecker")
    _par("D", display-name: "Session")
    _par("C", display-name: "HomePage")

    _seq("A", "B", enable-dst: true, comment: [Login `||` Register])
    _seq("B", "D", enable-dst: true, comment: [getAttribute("user")])
    _seq("D", "B", disable-src: true, comment: [return user $=>$ [`user != null`] ? Redirect])
    _seq("B", "C", disable-src: true, comment: [Redirect])
  }),
  comment: [
    The `UserChecker` filter checks, once the client accesses the Login or Register webpage, if the User is logged.

    #v(0.1em)

    If that's the case, then the program redirects to the HomePage. If not, then the `InvalidUserChecker` filter comes in.
  ],
  next_page: false,
)

#double_col_spaces(1cm)

#seq_diagram(
  "InvalidUserChecker",
  diagram({
    _par("A", display-name: "Client")
    _par("B", display-name: "InvalidUserChecker")
    _par("D", display-name: "Session")
    _par("C", display-name: "Login")

    _seq("A", "B", enable-dst: true, comment: [Home- `||` Playlist- `||` TrackPage])
    _seq("B", "D", enable-dst: true, comment: [getAttribute("user")])
    _seq("D", "B", disable-src: true, comment: [return user $=>$ [`user == null`] ? Redirect])
    _seq("B", "C", disable-src: true, comment: [Redirect])
  }),
  comment: [
    The `InvalidUserChecker` filter does the exact opposite of `UserChecker`. If the client accesses pages all the other pages -- HomePage, PlaylistPage, TrackPage -- and _is not logged in_, then the program redirects to the Login page.
  ],
  next_page: false,
)

// #balance([
//   The `PlaylistChecker` and `TrackChecker` filters are different from the precedent two because they don't simply implement the `Filter` interface, but instead extends `HttpFilter` class: this will become explained later.
// ])

#pagebreak()

#seq_diagram(
  "PlaylistChecker",
  diagram({
    _par("A", display-name: "Client")
    _par("B", display-name: "PlaylistChecker")
    _par("D", display-name: "Session")
    _par("F", display-name: "Request")
    _par("C", display-name: "PlaylistDAO")
    _par("E", display-name: `ERROR 403`, color: red.lighten(50%))

    _seq("A", "B", enable-dst: true, comment: [Playlist `||` AddTracks])
    _seq("B", "D", enable-dst: true, comment: [getAttribute ("user")])
    _seq("D", "B", disable-src: true, comment: [return user])
    _seq("B", "F", enable-dst: true, comment: [getParameter ("trackId")])
    _seq("F", "B", disable-src: true, comment: [return playlistId])
    _seq("B", "C", enable-dst: true, comment: [checkPlaylistOwner (playlistId, user)])
    _seq("C", "B", disable-src: true, comment: [return result $=>$ [result == false] ? sendError()])
    _seq("B", "E", disable-src: true, comment: [sendError("Playlist does not exist")])
  }),
  comment: [
    The `PlaylistChecker` filter is invoked in two scenario: after the User has clicked on a playlist on HomePage (@playlistpage-sequence) and when uploading a track (@uploadtrack-sequence).
    
    It is in charge of checking if the requested playlist _actually belongs_ to the User requesting or trying to upload it. This is done via obtaining the User attribute from the session -- which is impossibile without extending the `HttpServlet` or `HttpFilter` classes -- and getting the needed paramaters from the request.
    
    Finally, a query is performed against the database. If the result is false, then the server will respond with `ERROR 403: forbidden`.
  ],
  next_page: true,
)

#seq_diagram(
  "TrackChecker",
  diagram({
    _par("A", display-name: "Client")
    _par("B", display-name: "PlaylistChecker")
    _par("D", display-name: "Session")
    _par("F", display-name: "Request")
    _par("C", display-name: "TrackDAO")
    _par("E", display-name: `ERROR 403`, color: red.lighten(50%))

    _seq("A", "B", enable-dst: true, comment: [CreatePlaylist `||` AddTracks])
    _seq("B", "D", enable-dst: true, comment: [getAttribute ("user")])
    _seq("D", "B", disable-src: true, comment: [return user])
    _seq("B", "F", enable-dst: true, comment: [getParameter ("trackId")])
    _seq("F", "B", disable-src: true, comment: [return trackId])
    _seq("B", "C", enable-dst: true, comment: [checkTrackOwner (trackId, user)])
    _seq("C", "B", disable-src: true, comment: [return result $=>$ [result == false] ? sendError()])
    _seq("B", "E", disable-src: true, comment: [sendError("Track does not exist")])
  }),
  comment: [
    Even the `TrackChecker` filter is invoked in two scenario: during the creation of a playlist (@createplaylist-sequence) and during the UploadTrack sequence (@uploadtrack-sequence).

    `TrackChecker` applies a very similar pipeline `PlaylistChecker`: instead of checking the playlist, it does the same job but for one of more tracks when the User requests to add them to a playlist or when the User request to play one.

    Again similarly to `PlaylistChecker`, tt also obtains the User attribute from the session and the needed parameters; if the User does not have access rights to the requested track(s), the response is `ERROR 403`.
  ],
  next_page: false,
)
