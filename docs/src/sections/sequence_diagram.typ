#import "../lib.typ": *

#show: thymeleaf_trick.with()

= Sequence diagrams

#pagebreak()

#seq_diagram(
  "Login sequence diagram",
  diagram({
    _par("A", display-name: "Client")
    _par("B", display-name: "Login")
    _par("D", display-name: "UserDAO")
    _par("G", display-name: "Request")
    _par("H", display-name: "ctx")
    _par("C", display-name: "Thymeleaf", shape: "custom", custom-image: thymeleaf)
    _par("E", display-name: "Session")
    _par("F", display-name: "HomePage")

    // get
    _seq("A", "B", enable-dst: true, comment: "doGet()")
    _seq("B", "G", enable-dst: true, comment: [getParameter("error")])
    _seq("G", "B", disable-src: true, comment: [return error])
    _seq(
      "B",
      "H",
      comment: [[error != null && error == true] \ setVariable("error", true)],
    )
    _seq("B", "C", enable-dst: true, comment: "process(index.html, ctx)", lifeline-style: (fill: rgb("#005F0F")))
    _seq("C", "B", disable-src: true, comment: "index.html")
    _seq("B", "A", disable-src: true, comment: "index.html")

    // post
    _seq("A", "B", enable-dst: true, comment: "doPost()")
    _seq("B", "D", enable-dst: true, comment: "checkUser()")
    _seq("D", "B", disable-src: true, comment: "return schrödingerUser")
    _seq("B", "B", comment: [[schrödingerUser == null] \ ? redirect `/Login?error=true`])
    _seq("B", "E", comment: [[schrödingerUser != null] ? setAttribute("user", schrödingerUser)])
    _seq("B", "F", disable-src: true, comment: "Redirect")
  }),
  comment: [
    Once the server is up and running, the Client requests the Login page. Then, thymeleaf processes the request and returns the correct context, to index the chosen locale.\
    Afterwards, the User inserts their credentials.

    Those values are passed to the `checkUser()` function that returns `schrödingerUser` -- as the name implies, the variable might return a User; otherwise `null`. If `null`, then the credentials inserted do not match any record in the database; else the User is redirected to their HomePage and the `user` variable is set for the current session.

    If there has been some error in the process -- the credentials are incorrect, database can't be accessed... -- then the servlet will redirect to itself by setting the variable `error` to true, which then will be evaluated by thymeleaf and if true, it will print an error; otherwise it won't (this is the case for the first time the User inserts the credentials).
  ],
  label_: "login-sequence",
  comment_next_page_: false,
)

#seq_diagram(
  [Register sequence diagram],
  diagram({
    _par("A", display-name: "Client")
    _par("B", display-name: "Register")
    _par("H", display-name: "Request")
    _par("C", display-name: "Thymeleaf", shape: "custom", custom-image: thymeleaf)
    _par("D", display-name: "UserDAO")
    _par("F", display-name: "Login")
    // _par("G", display-name: "ctx")
    // _par("E", display-name: "Session")

    // get
    _seq("A", "B", enable-dst: true, comment: "doGet()")
    _seq("B", "H", enable-dst: true, comment: [getParameter("isUserAdded")])
    _seq("H", "B", disable-src: true, comment: [return isUserAdded])
    _seq("B", "C", enable-dst: true, comment: "process(register.html, ctx)", lifeline-style: (fill: rgb("#005F0F")))
    _seq("C", "B", disable-src: true, comment: "register.html")
    _seq("B", "A", disable-src: true, comment: "register.html")

    // post
    _seq("A", "B", enable-dst: true, comment: "doPost()")
    _seq("B", "H", enable-dst: true, comment: [getParameter("nickname")])
    _seq("H", "B", disable-src: true, comment: [return nickname])
    _seq("B", "H", enable-dst: true, comment: [getParameter("password")])
    _seq("H", "B", disable-src: true, comment: [return password])
    _seq("B", "H", enable-dst: true, comment: [getParameter("name")])
    _seq("H", "B", disable-src: true, comment: [return name])
    _seq("B", "H", enable-dst: true, comment: [getParameter("surname")])
    _seq("H", "B", disable-src: true, comment: [return surname])
    _seq("B", "D", enable-dst: true, comment: "addUser()")
    _seq("D", "B", disable-src: true, comment: "return isUserAdded")
    _seq("B", "F", comment: "[isUserAdded] ? redirect")
    _seq("B", "B", comment: [[!isUserAdded] \ ? redirect `/Registration?isUserAdded=false`])
    _seq("B", "C", enable-dst: true, comment: "process(register.html, ctx)", lifeline-style: (fill: rgb("#005F0F")))
    _seq("C", "B", disable-src: true, comment: "register.html")
    _seq("B", "A", disable-src: true, comment: "register.html")
  }),
  comment_next_page_: true,
  comment: [
    If the User is not yet registered, they might want to create an account. If that's the case, as per the Login sequence diagram, once all the parameters are gathered and verified (omitted for simplicity) initially thymeleaf processes the correct context, then the User inserts the credentials.

    Depending on the nickname inserted, the operation might fail: there can't be two Users with the same nickname. If that does not happen, then `isUserAdded` is `true`, then there will be the redirection to the Login page.

    Else the program appends `isUserAdded` with `false` value and redirects to the Registration servlet: thymeleaf checks for that context variable and if it evaluates to false, it prints an error.

  ],
  label_: "register-sequence",
)

#seq_diagram(
  [HomePage sequence diagram],
  diagram({
    _par("A", display-name: "Client")
    _par("B", display-name: "HomePage")
    _par("F", display-name: "Session")
    _par("C", display-name: "PlaylistDAO")
    _par("G", display-name: "Request")
    _par("D", display-name: "ctx")
    _par("E", display-name: "Thymeleaf", shape: "custom", custom-image: thymeleaf)

    _seq("A", "B", enable-dst: true, comment: "doGet()")
    _seq("B", "F", enable-dst: true, comment: [getAttribute("user")])
    _seq("F", "B", disable-src: true, comment: [return user])
    _seq("B", "C", enable-dst: true, comment: "getUserPlaylists(user)")
    _seq("C", "B", disable-src: true, comment: "return playlists")
    _seq("B", "C", enable-dst: true, comment: "getUserTracks(user)")
    _seq("C", "B", disable-src: true, comment: "return userTracks")
    _seq("B", "G", enable-dst: true, comment: [getParameter("duplicateTrack")])
    _seq("G", "B", disable-src: true, comment: [return duplicateTrack])
    _seq("B", "G", enable-dst: true, comment: [getParameter("duplicatePlaylist")])
    _seq("G", "B", disable-src: true, comment: [return duplicatePlaylist])
    _seq("B", "D", comment: [[duplicateTrack != null && duplicateTrack == true] \ setVariable("duplicateTrack", true)])
    _seq(
      "B",
      "D",
      comment: [[duplicatePlaylist != null && duplicatePlaylist == true] \ setVariable("duplicatePlaylist", true)],
    )
    _seq("B", "D", comment: [setVariable("userTracks", userTracks)])
    _seq("B", "D", comment: [setVariable("playlists", Playlists)])
    _seq("B", "D", comment: [setVariable("genres", genres)])
    _seq("B", "E", enable-dst: true, comment: "process(home_page, ctx)", lifeline-style: (fill: rgb("#005F0F")))
    _seq("E", "B", disable-src: true, comment: "home_page.html")
    _seq("B", "A", disable-src: true, comment: "home_page.html")
  }),
  comment_next_page_: true,
  comment: [
    Once the Login is complete, the User is redirected to their HomePage, which hosts all their Playlists. In order to do so, the program needs to User attribute -- which is retrieved via the session; then, it is passed to the `getUserPlaylists` function and finally thymeleaf displays all values.

    From this page, the User can upload new tracks. for this reason the HomePage servlet fetches all the user tracks (which are not to be displayed). Then, as the User presses the upload button, the modal shows up allowing to fill the information for a new track (title, album, path, playlist...); the genres are predetermined: they are statically loaded from the `genres.json` file.

    Once the information are completed, the servlet checks if a playlist or track is duplicate -- hence the need to fetch all the tracks -- and if so it redirectes to itself with a `duplicate-` error, the same principle applied to the precedent servlets. Otherwise, the track would have been successfully added.
  ],
  label_: "homepage-sequence",
)

#seq_diagram(
  [PlaylistPage sequence diagram],
  diagram({
    _par("A", display-name: "HomePage")
    _par("B", display-name: "PlaylistPage")
    _par("F", display-name: "Session")
    _par("G", display-name: "Request")
    _par("C", display-name: "PlaylistDAO")
    _par("D", display-name: "ctx")
    _par("E", display-name: "Thymeleaf", shape: "custom", custom-image: thymeleaf)

    _seq("A", "B", enable-dst: true, comment: "doGet()")
    _seq("B", "F", enable-dst: true, comment: [getAttribute("user")])
    _seq("F", "B", disable-src: true, comment: [return user])
    _seq("B", "G", enable-dst: true, comment: [getParameter("playlist_title")])
    _seq("G", "B", disable-src: true, comment: [return playlistTitle])
    _seq("B", "G", enable-dst: true, comment: [getParameter("gr")])
    _seq("G", "B", disable-src: true, comment: [return trackGroupString])
    _seq("B", "C", enable-dst: true, comment: "getPlaylistTracks(playlistTitle, user)")
    _seq("C", "B", disable-src: true, comment: "return Playlists")
    _seq("B", "C", enable-dst: true, comment: "getTrackGroup(playlistId, trackGroup)")
    _seq("C", "B", disable-src: true, comment: "return playlistTracks")
    _seq("B", "C", enable-dst: true, comment: "getTracksNotInPlaylist(playlistTitle, user.id())")
    _seq("C", "B", disable-src: true, comment: "return addableTracks")
    _seq("B", "D", comment: [setVariable("trackGroup", trackGroup)])
    _seq("B", "D", comment: [setVariable("playlistId", playlistId)])
    _seq("B", "D", comment: [setVariable("playlistsTitle", playlistTitle)])
    _seq("B", "D", comment: [setVariable("addableTracks", addableTracks)])
    _seq("B", "D", comment: [setVariable("playlistTracks", playlistTracks)])
    _seq("B", "E", enable-dst: true, comment: "process(playlist_page, ctx)", lifeline-style: (fill: rgb("#005F0F")))
    _seq("E", "B", disable-src: true, comment: "playlist_page.html")
    _seq("B", "A", disable-src: true, comment: "playlist_page.html")
  }),
  comment: [
    From the HomePage, the User is able to see all their playlists. By clicking on either one of them, the program redirects to the corresponding PlaylistPage, which lists all the tracks associated to that playlist.

    In order to do so, the program needs the User attribute -- which is retrieved via the session -- and the title of the playlists, which is given as a parameter by pressing the corresponding button in HomePage.

    Then those value are passed to `getPlaylistTracks()`, that returns all the tracks. Finally, thymeleaf processes the context and display all the tracks.

    From this page the User is also able to add chosen tracks to a playlist. In order to do, similar to HomePage with the upload, the program fetches all tracks that _can be added_, thats is the ones that are not already in a playlist, and displays them to a User via a dropdown menu (again similar to genres in HomePage).
  ],
  label_: "playlistpage-sequence",
  comment_next_page_: true,
)

#seq_diagram(
  [Track sequence diagram],
  scale(
    100%,
    diagram({
      _par("A", display-name: "Client")
      _par("B", display-name: "Track")
      _par("F", display-name: "Session")
      _par("G", display-name: "Request")
      _par("C", display-name: "TrackDAO")
      // _par("H", display-name: [`ERROR 404`], color: red.lighten(50%))
      _par("D", display-name: "ctx")
      // _par("H", display-name: `ERROR 500`)
      _par("E", display-name: "Thymeleaf", shape: "custom", custom-image: thymeleaf)

      _seq("A", "B", enable-dst: true, comment: "doGet()")
      _seq("B", "F", enable-dst: true, comment: [getAttribute("user")])
      _seq("F", "B", disable-src: true, comment: [return user])
      _seq("B", "G", enable-dst: true, comment: [getParameter("track_id")])
      _seq("G", "B", disable-src: true, comment: [return trackId])
      // _seq("B", "C", enable-dst: true, comment: "checkTrackOwner(trackId, user)")
      // _seq("C", "B", disable-src: true, comment: "return isOwner")
      // _seq("B", "H", comment: [[isOwner == false] sendError("Track does not exist")])
      _seq("B", "C", enable-dst: true, comment: "getTrackById(trackId)")
      _seq("C", "B", disable-src: true, comment: "return track")
      _seq("B", "D", comment: [setVariable("track", track)])
      _seq("B", "E", enable-dst: true, comment: "process(player_page, ctx)", lifeline-style: (fill: rgb("#005F0F")))
      _seq("E", "B", disable-src: true, comment: "player_page.html")
      _seq("B", "A", disable-src: true, comment: "player_page.html")
    }),
  ),
  comment: [
    Once the program has lodead all the tracks associated to a playlist, it allows to play them one by one in the dedicated player page. In a similar fashion to the `getPlaylistTracks()` method, in order to retrieve all the information regarding a single track the program is given the `track_id` parameter by pressing the corresponding button.

    Finally, `getTrackById()` returns the track metadata -- that is title, artist, album, path and album image -- thymeleaf then processes the context and displays all the information. If an exception is caught during this operation, the server will respond with `ERROR 500` (see @trackchecker-filter).
  ],
  label_: "track-sequence",
)

#seq_diagram(
  [UploadTrack sequence diagram],
  diagram({
    _par("A", display-name: "Client")
    _par("B", display-name: "UploadTrack")
    _par("E", display-name: "Track")
    _par("C", display-name: "TrackDAO")
    _par("F", display-name: "File")
    _par("G", display-name: "Files")
    _par("D", display-name: "HomePage")

    _seq("A", "B", enable-dst: true, comment: "doPost()")
    _note("right", [POST /UploadTrack \ title, artist, album, year, \ genre, musicTrack, image])
    _seq("B", "B", enable-dst: true, comment: [imagePath = processPart(image, "image")])
    _seq("B", "B", comment: [imageHash = getSHA256Hash(image\ .getInputStream().readAllBytes())])
    _seq("B", "C", enable-dst: true, comment: [relativeFilePath = isImageFileAlreadyPresent(hash)])
    _seq("C", "B", disable-src: true, comment: [return path || null])
    _alt(
      "relativeFilePath==null",
      {
        _seq("B", "F", comment: [outputFile = new File(realOutputFilePath)])
        _seq("B", "G", comment: [copy(image.getInputStream(), outputFile.toPath())])
        _seq(
          "B",
          "B",
          comment: [newFiles.add(outputFile) \ relativeFilePath = relativeOutputFolder \ + File.separator + mimetype \ + File.separator + outputFile.getName()],
        )
      },
    )
    _seq("B", "B", disable-src: true, comment: [return relativeFilePath])
    _seq("B", "B", comment: [songPath = processPart(musicTrack, "audio")])
    _seq("B", "E", comment: [track = new Track(...)])
    _alt(
      "try",
      { _seq("B", "C", comment: [addTrack(track)]) },
      "catch SQLException",
      { _seq("B", "B", comment: [newFiles.forEach(file -> file.delete())]) },
      [finally],
      {
        _seq("B", "B", comment: [newFiles.clear()])
      },
    )
    _seq("B", "D", disable-src: true, comment: [Redirect])
  }),
  comment: [
    The User can upload tracks from the appropriate form in the homepage (@homepage-sequence). When the POST request is received, the request parameters are checked for null values and emptiness (omitted in the diagram for the sake of simplicity), and the uploaded files are written to disk by the `processPart` method, which has two parameters: a Part object, which "represents a part or form item that was received within a multipart/form-data POST request" @part, and its expected MIME type. The latter does not need to be fully specified (i.e. the subtype can be omitted).

    Before writing the file to disk, the method checks for duplicates of the file by calculating its SHA256 hash and querying the database with the two methods: `isTrackFileAlreadyPresent` and `isImageFileAlreadyPresent`; present in TrackDAO.

    Those two return the relative file path corresponding to the file hash if a matching one is found, otherwise null. In the former case, `processPart` returns the found path and the new track is uploaded using the already present file, this avoiding creating duplicates; in the latter case `processPart` proceeds by writing the file to disk and returning the new file's path.

    To write the file to the correct path in the webapp folder (`realOutputFolder`), the method `context.getRealPath(relativeOutputFolder)` is called, where `relativeOutputFolder` is obtained from the `web.xml` file and is, in our case, `"uploads"`; `realOutputFolder` is obtained by appending, with the needed separators, the MIME type to the result of `getRealPath`; to get `realOutputFilePath`, a random UUID and the file extension are appended to `realOutputFolder`. Having obtained the desired path, the file can be created and then written with the `Files.copy` method. The file can be found in target/#emph[artifactId]-#emph[version]/uploads/ in the project folder.

    In conclusion, `processPart` adds the new file to the newFiles list in `UploadTrack` and returns the path relative to the webapp folder because that's where the application will be looking for when it has to retrieve files. Once this is completed, the new Track object is created and passed to the `addTrack` method of TrackDAO; if an `SQLException` is thrown, all the files in `newFiles` list are deleted and then, in the finally block, the list is cleared.
  ],
  label_: "uploadtrack-sequence",
)

#seq_diagram(
  [CreatePlaylist sequence diagram],
  diagram({
    _par("A", display-name: "Client")
    _par("B", display-name: "CreatePlaylistTrack")
    _par("C", display-name: "AddTracksToPlaylist")
    _par("G", display-name: "Request")
    _par("E", display-name: "PlaylistDAO")
    _par("D", display-name: "HomePage")

    _seq("A", "B", enable-dst: true, comment: "doPost()")
    _seq("B", "G", enable-dst: true, comment: [getParameter("playlistTitle")])
    _seq("G", "B", disable-src: true, comment: [return playlistTitle])
    _seq("B", "G", enable-dst: true, comment: [getParameterValues("selectedTracks")])
    _seq("G", "B", disable-src: true, comment: [return selectedTracks])
    _seq("B", "E", enable-dst: true, comment: [createPlaylist(playlistTitle)])
    _seq("E", "B", disable-src: true, comment: [return playlistId])
    _alt(
      "!selectedTracksIds.isEmpty()",
      {
        _seq("B", "E", comment: [addTracksToPlaylist(playlistId,selectedTracksIds)])
      },
    )
    _seq("B", "D", disable-src: true, comment: [Redirect])
  }),
  comment: [
    The user can create playlists with the appropriate form in the homepage. There, a title needs to be inserted and, optionally, one or more tracks can be chosen from the ones uploaded by the user. When the servlet gets the POST request, it interacts with the PlaylistDAO to create the playlist with the createPlaylist method and to add the selected tracks with the addTracksToPlaylist method.

    Note that selectedTracksIds is a list of integers obtained by converting the strings inside the array returned by getParameterValues("selectedTracks") with the Integer.parseInt method.
  ],
  label_: "createplaylist-sequence",
  comment_next_page_: false,
)

#seq_diagram(
  [Logout sequence diagram],
  diagram({
    _par("A", display-name: "Client")
    _par("B", display-name: "Logout")
    _par("C", display-name: "Request")
    _par("D", display-name: "Login")

    _seq("A", "B", enable-dst: true, comment: "doGet()")
    _seq("B", "C", enable-dst: true, comment: [getSession(false)])
    _seq("C", "B", disable-src: true, comment: [return session $=>$ [session != null] ? session.invalidate()])
    _seq("B", "D", disable-src: true, comment: "Redirect")
  }),
  comment: [
    From every web page except Login and Register, the User is able to logout, at any moment. It's a simple `GET` request to the Logout servlet, which checks if the `user` session attribute exists; if it does, then it invalidates the session and redirects the User to the Login page.
  ],
  label_: "logout-sequence",
  comment_next_page_: false,
  next_page: false
)

#seq_diagram(
  [AddTracks sequence diagram],
  diagram({
    _par("A", display-name: "Client")
    _par("B", display-name: "addTracksToPlaylist")
    _par("C", display-name: "Session")
    _par("D", display-name: "Request")
    _par("E", display-name: "PlaylistDAO")

    _seq("A", "B", enable-dst: true, comment: "doPost()")
    _seq("B", "C", enable-dst: true, comment: [getAttribute("user")])
    _seq("C", "B", disable-src: true, comment: [return user])
    _seq("B", "D", enable-dst: true, comment: [getParameterValues("selectedTracks")])
    _seq("D", "B", disable-src: true, comment: [return selectedTracksIds])
    _seq("B", "D", enable-dst: true, comment: [getParameter("playlistId")])
    _seq("D", "B", disable-src: true, comment: [return playlistId])
    _seq("B", "E", disable-src: true, comment: [addTracksToPlaylist(selectedTracksIds, playlistId)])
    // _seq("D", "A", comment: [scCreated])
  }),
  comment: [
    From the modal, once the User has completed the selection of the Tracks to add in the current Playlist, the form calls the `AddTracks` servlet via a POST method.

    Afterwards, by making sure there are no `nulls` in the `selectedTracksIds`, the `addTracksToPlaylist` method is called: it performs an insertion in the `playlist_tracks` table. Finally, the User is redirected to the newly created Playlist.

    #ria() In the RIA subproject, the servlet response with a `201` code instead of redirecting.
  ],
  label_: "add-tracks-sequence",
  comment_next_page_: false,
  next_page: false
)

#seq_diagram(
  [#ria() GetTracksNotInPlaylist sequence diagram],
  diagram({
    _par("A", display-name: "Client")
    _par("B", display-name: "GetTracksNotInPlaylist")
    _par("C", display-name: "Session")
    _par("D", display-name: "Request")
    _par("E", display-name: "PlaylistDAO")
    _par("F", display-name: "Gson")

    _seq("A", "B", enable-dst:true, comment: "doGet()")
    _seq("B", "C", enable-dst:true, comment: [getAttribute("user")])
    _seq("C", "B", disable-src:true, comment: [return user])
    _seq("B", "D", enable-dst:true, comment: [getParameter("playlistTitle")])
    _seq("D", "B", disable-src:true, comment: [return playlistTitle])
    _seq("B", "E", enable-dst:true, comment: [getTracksNotInPlaylist(playlistTitle,user.id())])
    _seq("E", "B", disable-src:true, comment: [return userTracks])
    _seq("B", "F", enable-dst:true, comment: [gson.toJson(userTracks)])
    _seq("F", "B", disable-src: true, comment: [return userTracks])
    _seq("B", "A", disable-src:true, comment: [userTracks])
  }),
  comment:[
    As the name suggests, this servlet obtains the tracks are _not_ in the given Playlist, in order to display them when the User wants to add a new track to a Playlist -- this happens when the User clicks on the corresponding button.

    Then, the User attribute is retrieved from the session while the playlist title from the request.

    In conclusion, the tracks that are not in the playlist are retrieved by the `getTracksNotInPlaylist` method: it returns a list which is converted to a JSON object via Gson for JavaScript.

    // Once the needed parameters are obtained, the `getTracksNotInPlaylist` method returns the track, which are converted to a JSON.
  ],
  label_ : "get-tracks-not-in-playlist-sequence",
  comment_next_page_: false,
)

#seq_diagram(
  [#ria() TrackReorder sequence diagram],
  diagram({
    _par("A", display-name: "Client")
    _par("B", display-name: "TrackReorder")
    _par("C", display-name: "Request")
    _par("E", display-name: "Gson")
    _par("D", display-name: "PlaylistDAO")

    _seq("A", "B", enable-dst:true, comment: "doGet()")
    // _seq("B", "C", enable-dst:true, comment: [getParameter("playlistId")])
    // _seq("C", "B", disable-src:true, comment: [return playlistId)])
    // _seq("B", "C", enable-dst:true, comment: [getParameter("trackId")])
    // _seq("C", "B", disable-src:true, comment: [return trackId)])
    // _seq("B", "C", enable-dst:true, comment: [getParameter("newOrder")])
    // _seq("C", "B", disable-src:true, comment: [return newOrder)])
    _seq("B", "C", enable-dst:true, comment: [getReader])
    _seq("C", "B", disable-src:true, comment: [return reader])
    _seq("B", "E", enable-dst:true, comment: [gson.fromJson(reader)])
    _seq("E", "B", disable-src:true, comment: [return requestData])
    _seq("B", "D", disable-src:true, comment: [
      updateTrackOrder(requestData.trackIds(),\ requestData.playlistId())
    ])
  }),
  comment:[
    // It obtains the needed parameters from the request -- the ID of the playlist, the ID of the track and the new order of said track -- and simply makes a POST request to the servlet, which invokes the updateTrackOrder method.

    // Once the needed parameters are obtained, the `updateTrackOrder()` method updates the `playlist_tracks` table.

    This servlet obtains the needed parameters by leveraging a JSON and a Record class. Javascript parses all the information and then sends them as a JSON to Java, which maps it all to the `RequestData` record class.

    Afterwards, the `tracksIds` and `playlistId` attributes are passed to the `updateTrackOrder` method that loads multiple insertions in the database: instead of iterating and performing a query at each cycle, it prepares a transaction to be committed _one single time_.
  ],
  label_ : "track-reordering-sequence",
  comment_next_page_: false
)

#seq_diagram(
  [#ria() GetUserTracks sequence diagram],
  diagram({
    _par("A", display-name: "Client")
    _par("B", display-name: "GetUserTracks")
    _par("C", display-name: "TrackDAO")
    _par("D", display-name: "Session")
    _par("E", display-name: "Gson")

    _seq("A", "B", comment: ["doGet()"])
    _seq("B", "C", comment: [getAttribute("user")])
    _seq("C", "B", comment: [return user])
    _seq("B", "C", comment: [getUserTracks(user)])
    _seq("C", "B", comment: [return userTracks])
    _seq("B", "E", comment: [gson.toJson(userTracks)])
    _seq("E", "B", comment: [return userTracks[JSON]])
  }),
  comment:[
    As the name implies, this servlet retrieves all the Tracks associated to a User. This is fetched as usually from the session.

    Similar to the previous sequences, once it retrieves the track from the database, the list is transformed into a JSON by Gson and finally sent to the browser.
  ],
  label_ : "get-user-tracks-sequence",
  comment_next_page_: false
)
