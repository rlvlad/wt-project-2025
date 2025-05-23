#import "../lib.typ": *

#show: thymeleaf_trick.with()

= Sequence diagrams

#pagebreak()

#seq_diagram(
  "Login sequence diagram",
  diagram({
    _par("A", display-name: "Client")
    _par("B", display-name: "Login")
    _par("G", display-name: "Request")
    _par("H", display-name: "ctx")
    _par("C", display-name: "Thymeleaf", shape: "custom", custom-image: thymeleaf)
    _par("D", display-name: "UserDAO")
    _par("E", display-name: "Session")
    _par("F", display-name: "HomePage")

    // get
    _seq("A", "B", enable-dst: true, comment: "doGet()")
    _seq("B", "G", enable-dst: true, comment: [getParameter ("error")])
    _seq("G", "B", disable-src: true, comment: [return error])
    _seq(
      "B",
      "H",
      comment: [[error != null && error == true] \ ? setVariable ("error", true)],
    )
    _seq("B", "C", enable-dst: true, comment: "process(index.html, ctx)", lifeline-style: (fill: rgb("#005F0F")))
    _seq("C", "B", disable-src: true, comment: "index.html")
    _seq("B", "A", disable-src: true, comment: "index.html")

    // post
    _seq("A", "B", enable-dst: true, comment: "doPost()")
    _seq("B", "D", enable-dst: true, comment: [getParameter ("nickname")])
    _seq("D", "B", disable-src: true, comment: [return nickname])
    _seq("B", "D", enable-dst: true, comment: [getParameter ("password")])
    _seq("D", "B", disable-src: true, comment: [return password])
    _seq("B", "D", enable-dst: true, comment: "checkUser (nickname,password)")
    _seq("D", "B", disable-src: true, comment: "return schrödingerUser")
    _seq("B", "B", comment: [[schrödingerUser == null] \ ? redirect `/Login?error=true`])
    _seq("B", "E", comment: [[schrödingerUser != null] \ ? setAttribute("user", schrödingerUser)])
    _seq("B", "F", disable-src: true, comment: "Redirect")
  }),
  comment: [
    Once the server is up and running, the Client requests the Login page. Then, thymeleaf processes the request and returns the correct context, to index the chosen locale. Afterwards, the User inserts their credentials.

    Those values are passed to the `checkUser()` function that returns `schrödingerUser` -- as the name implies, the variable might return a User; otherwise `null`. If `null`, then the credentials inserted do not match any record in the database; else the User is redirected to their HomePage and the `user` variable is set for the current session.

    If there has been some error in the process -- the credentials are incorrect, database can't be accessed... -- then the servlet will redirect to itself by setting the variable `error` to true, which then will be evaluated by thymeleaf and if true, it will print an error; otherwise it won't (this is the case for the first time the User inserts the credentials).
  ],
  label_: "login-sequence",
  comment_next_page_: true,
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
    _seq("B", "H", enable-dst: true, comment: [getParameter ("isUserAdded")])
    _seq("H", "B", disable-src: true, comment: [return isUserAdded])
    _seq("B", "C", enable-dst: true, comment: "process (register.html, ctx)", lifeline-style: (fill: rgb("#005F0F")))
    _seq("C", "B", disable-src: true, comment: "register.html")
    _seq("B", "A", disable-src: true, comment: "register.html")

    // post
    _seq("A", "B", enable-dst: true, comment: "doPost()")
    _seq("B", "H", enable-dst: true, comment: [getParameter ("nickname")])
    _seq("H", "B", disable-src: true, comment: [return nickname])
    _seq("B", "H", enable-dst: true, comment: [getParameter ("password")])
    _seq("H", "B", disable-src: true, comment: [return password])
    _seq("B", "H", enable-dst: true, comment: [getParameter ("name")])
    _seq("H", "B", disable-src: true, comment: [return name])
    _seq("B", "H", enable-dst: true, comment: [getParameter ("surname")])
    _seq("H", "B", disable-src: true, comment: [return surname])
    _seq("B", "D", enable-dst: true, comment: "addUser (user)")
    _seq("D", "B", disable-src: true, comment: "return isUserAdded")
    _seq("B", "F", comment: "[isUserAdded] ? redirect")
    _seq("B", "B", comment: [[!isUserAdded] \ ? redirect `/Registration?isUserAdded=false`])
    _seq("B", "C", enable-dst: true, comment: "process (register.html, ctx)", lifeline-style: (fill: rgb("#005F0F")))
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
    _seq("B", "F", enable-dst: true, comment: [getAttribute ("user")])
    _seq("F", "B", disable-src: true, comment: [return user])
    _seq("B", "C", enable-dst: true, comment: "getUserPlaylists (user)")
    _seq("C", "B", disable-src: true, comment: "return playlists")
    _seq("B", "C", enable-dst: true, comment: "getUserTracks (user)")
    _seq("C", "B", disable-src: true, comment: "return userTracks")
    _seq("B", "G", enable-dst: true, comment: [getParameter ("duplicateTrack")])
    _seq("G", "B", disable-src: true, comment: [return duplicateTrack])
    _seq(
      "B",
      "D",
      comment: [[duplicateTrack != null && duplicateTrack == true] \ ? setVariable("duplicateTrack", true)],
    )
    _seq("B", "G", enable-dst: true, comment: [getParameter ("duplicatePlaylist")])
    _seq("G", "B", disable-src: true, comment: [return duplicatePlaylist])
    _seq(
      "B",
      "D",
      comment: [[duplicatePlaylist != null && duplicatePlaylist == true] \ ? setVariable("duplicatePlaylist", true)],
    )
    _seq("B", "D", comment: [setVariable ("userTracks", userTracks)])
    _seq("B", "D", comment: [setVariable ("playlists", Playlists)])
    _seq("B", "D", comment: [setVariable ("genres", genres)])
    _seq("B", "E", enable-dst: true, comment: "process (home_page.html, ctx)", lifeline-style: (fill: rgb("#005F0F")))
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
  [Playlist sequence diagram],
  diagram({
    _par("A", display-name: "HomePage")
    _par("B", display-name: "Playlist")
    _par("F", display-name: "Session")
    _par("G", display-name: "Request")
    _par("C", display-name: "PlaylistDAO")
    _par("D", display-name: "ctx")
    _par("E", display-name: "Thymeleaf", shape: "custom", custom-image: thymeleaf)

    _seq("A", "B", enable-dst: true, comment: "doGet()")
    _seq("B", "F", enable-dst: true, comment: [getAttribute ("user")])
    _seq("F", "B", disable-src: true, comment: [return user])
    _seq("B", "G", enable-dst: true, comment: [getParameter ("playlistId")])
    _seq("G", "B", disable-src: true, comment: [return playlistId])
    _seq("B", "G", enable-dst: true, comment: [getParameter ("gr")])
    _seq("G", "B", disable-src: true, comment: [return trackGroupString])
    _seq("B", "C", enable-dst: true, comment: [getPlaylistTitle (playlistId)])
    _seq("C", "B", disable-src: true, comment: "return playlistTitle")
    _seq("B", "C", enable-dst: true, comment: "getTrackGroup (playlistId, trackGroup)")
    _seq("C", "B", disable-src: true, comment: "return playlistTracks")
    _seq("B", "C", enable-dst: true, comment: "getTracksNotInPlaylist (playlistTitle, user.id())")
    _seq("C", "B", disable-src: true, comment: "return addableTracks")
    _seq("B", "D", comment: [setVariable("trackGroup", trackGroup)])
    _seq("B", "D", comment: [setVariable("playlistId", playlistId)])
    _seq("B", "D", comment: [setVariable("playlistTitle", playlistTitle)])
    _seq("B", "D", comment: [setVariable("addableTracks", addableTracks)])
    _seq("B", "D", comment: [setVariable("playlistTracks", playlistTracks)])
    _seq("B", "E", enable-dst: true, comment: "process (playlist_page, ctx)", lifeline-style: (fill: rgb("#005F0F")))
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
  diagram({
    _par("A", display-name: "Client")
    _par("B", display-name: "Track")
    _par("G", display-name: "Request")
    _par("C", display-name: "TrackDAO")
    _par("D", display-name: "ctx")
    _par("E", display-name: "Thymeleaf", shape: "custom", custom-image: thymeleaf)

    _seq("A", "B", enable-dst: true, comment: "doGet()")
    _seq("B", "G", enable-dst: true, comment: [getParameter ("track_id")])
    _seq("G", "B", disable-src: true, comment: [return trackId])
    _seq("B", "C", enable-dst: true, comment: "getTrackById (trackId)")
    _seq("C", "B", disable-src: true, comment: "return track")
    _seq("B", "D", comment: [setVariable("track", track)])
    _seq("B", "E", enable-dst: true, comment: "process (player_page, ctx)", lifeline-style: (fill: rgb("#005F0F")))
    _seq("E", "B", disable-src: true, comment: "player_page.html")
    _seq("B", "A", disable-src: true, comment: "player_page.html")
  }),
  comment: [
    Once the program has lodead all the tracks associated to a playlist, it allows to play them one by one in the dedicated player page. In a similar fashion to the `getPlaylistTracks()` method, in order to retrieve all the information regarding a single track the program is given the `track_id` parameter by pressing the corresponding button.

    Finally, `getTrackById()` returns the track metadata -- that is title, artist, album, path and album image -- thymeleaf then processes the context and displays all the information. If an exception is caught during this operation, the server will respond with `ERROR 500` (see @trackchecker-filter).
  ],
  label_: "track-sequence",
  comment_next_page_: false,
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
    _seq("B", "B", enable-dst: true, comment: [fileDetails = processPart(image, "image")])
    _seq("B", "B", comment: [hash = getSHA256Hash(image\ .getInputStream().readAllBytes())])
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
    _seq("B", "B", disable-src: true, comment: [return new FileDetails(relativeFilePath, hash)])
    _seq("B", "B", comment: [fileDetails = processPart(musicTrack, "audio")])
    _seq("B", "E", comment: [track = new Track(...)])
    _alt(
      "try",
      {
        _seq("B", "C", comment: [addTrack(track)])
        _seq("B", "D", comment: [Redirect])
      },
      "catch SQLException",
      { _seq("B", "B", comment: [newFiles.forEach(file -> file.delete())]) },
      [finally],
      {
        _seq("B", "B", disable-src: true, comment: [newFiles.clear()])
      },
    )
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
    _seq("B", "G", enable-dst: true, comment: [getParameter ("playlistTitle")])
    _seq("G", "B", disable-src: true, comment: [return playlistTitle])
    _seq("B", "G", enable-dst: true, comment: [getParameterValues ("selectedTracks")])
    _seq("G", "B", disable-src: true, comment: [return selectedTracks])
    _seq("B", "E", enable-dst: true, comment: [createPlaylist (playlistTitle)])
    _seq("E", "B", disable-src: true, comment: [return playlistId])
    _seq(
      "B",
      "E",
      comment: [
        !selectedTracksIds.isEmpty() \
        ? addTracksToPlaylist (playlistId,selectedTracksIds)
      ],
    )
    // _alt(
    //   "!selectedTracksIds.isEmpty()",
    //   {
    //     _seq("B", "E", comment: [addTracksToPlaylist (playlistId,selectedTracksIds)])
    //   },
    // )
    _seq("B", "D", disable-src: true, comment: [Redirect])
  }),
  comment: [
    The User can create playlists with the appropriate form in the homepage. There, a title needs to be inserted and, optionally, one or more tracks can be chosen from the ones uploaded by the User. When the servlet gets the POST request, it interacts with the PlaylistDAO to create the playlist with the `createPlaylist()` method and to add the selected tracks with the `addTracksToPlaylist()` method.

    Note that selectedTracksIds is a list of integers obtained by converting the strings inside the array returned by the `getParameterValues("selectedTracks")` method with `Integer.parseInt()`.
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
    _seq("B", "C", enable-dst: true, comment: [getSession (false)])
    _seq("C", "B", disable-src: true, comment: [return session $=>$ [session != null] ? session.invalidate()])
    _seq("B", "D", disable-src: true, comment: "Redirect")
  }),
  comment: [
    From every web page except Login and Register, the User is able to logout, at any moment. It's a simple `GET` request to the Logout servlet, which checks if the `user` session attribute exists; if it does, then it invalidates the session and redirects the User to the Login page.
  ],
  label_: "logout-sequence",
  comment_next_page_: false,
  next_page: false,
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
    _seq("B", "C", enable-dst: true, comment: [getAttribute ("user")])
    _seq("C", "B", disable-src: true, comment: [return user])
    _seq("B", "D", enable-dst: true, comment: [getParameterValues ("selectedTracks")])
    _seq("D", "B", disable-src: true, comment: [return selectedTracksIds])
    _seq("B", "D", enable-dst: true, comment: [getParameter ("playlistId")])
    _seq("D", "B", disable-src: true, comment: [return playlistId])
    _seq("B", "E", disable-src: true, comment: [addTracksToPlaylist (selectedTracksIds, playlistId)])
    // _seq("D", "A", comment: [scCreated])
  }),
  comment: [
    From the modal, once the User has completed the selection of the Tracks to add in the current Playlist, the form calls the `AddTracks` servlet via a POST method.

    Afterwards, by making sure there are no `nulls` in the `selectedTracksIds`, the `addTracksToPlaylist` method is called: it performs an insertion in the `playlist_tracks` table. Finally, the User is redirected to the newly created Playlist.

    #ria() In the RIA subproject, the servlet response with a `201` code instead of redirecting.
  ],
  label_: "add-tracks-sequence",
  comment_next_page_: false,
  next_page: false,
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

    _seq("A", "B", enable-dst: true, comment: "doGet()")
    _seq("B", "C", enable-dst: true, comment: [getAttribute ("user")])
    _seq("C", "B", disable-src: true, comment: [return user])
    _seq("B", "D", enable-dst: true, comment: [getParameter ("playlistTitle")])
    _seq("D", "B", disable-src: true, comment: [return playlistTitle])
    _seq("B", "E", enable-dst: true, comment: [getTracksNotInPlaylist (playlistTitle,user.id())])
    _seq("E", "B", disable-src: true, comment: [return userTracks])
    _seq("B", "F", enable-dst: true, comment: [toJson (userTracks)])
    _seq("F", "B", disable-src: true, comment: [return userTracks[JSON]])
    _seq("B", "A", disable-src: true, comment: [userTracks])
  }),
  comment: [
    As the name suggests, this servlet obtains the tracks are _not_ in the given Playlist, in order to display them when the User wants to add a new track to a Playlist -- this happens when the User clicks on the corresponding button.

    Then, the User attribute is retrieved from the session while the playlist title from the request.

    In conclusion, the tracks that are not in the playlist are retrieved by the `getTracksNotInPlaylist` method: it returns a list which is converted to a JSON object via Gson for JavaScript.

    // Once the needed parameters are obtained, the `getTracksNotInPlaylist` method returns the track, which are converted to a JSON.
  ],
  label_: "get-tracks-not-in-playlist-sequence",
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

    _seq("A", "B", enable-dst: true, comment: "doGet()")
    // _seq("B", "C", enable-dst:true, comment: [getParameter("playlistId")])
    // _seq("C", "B", disable-src:true, comment: [return playlistId)])
    // _seq("B", "C", enable-dst:true, comment: [getParameter("trackId")])
    // _seq("C", "B", disable-src:true, comment: [return trackId)])
    // _seq("B", "C", enable-dst:true, comment: [getParameter("newOrder")])
    // _seq("C", "B", disable-src:true, comment: [return newOrder)])
    _seq("B", "C", enable-dst: true, comment: [getReader])
    _seq("C", "B", disable-src: true, comment: [return reader])
    _seq("B", "E", enable-dst: true, comment: [fromJson(reader)])
    _seq("E", "B", disable-src: true, comment: [return requestData])
    _seq(
      "B",
      "D",
      disable-src: true,
      comment: [
        updateTrackOrder(requestData.trackIds(),\ requestData.playlistId())
      ],
    )
  }),
  comment: [
    // It obtains the needed parameters from the request -- the ID of the playlist, the ID of the track and the new order of said track -- and simply makes a POST request to the servlet, which invokes the updateTrackOrder method.

    // Once the needed parameters are obtained, the `updateTrackOrder()` method updates the `playlist_tracks` table.

    This servlet obtains the needed parameters by leveraging a JSON and a Record class. Javascript parses all the information and then sends them as a JSON to Java, which maps it all to the `RequestData` record class.

    Afterwards, the `tracksIds` and `playlistId` attributes are passed to the `updateTrackOrder` method that loads multiple insertions in the database: instead of iterating and performing a query at each cycle, it prepares a transaction to be committed _one single time_.
  ],
  label_: "track-reordering-sequence",
  comment_next_page_: false,
)

#seq_diagram(
  [#ria() GetUserTracks sequence diagram],
  diagram({
    _par("A", display-name: "Client")
    _par("B", display-name: "GetUserTracks")
    _par("C", display-name: "TrackDAO")
    // _par("D", display-name: "Session")
    _par("E", display-name: "Gson")

    _seq("A", "B", enable-dst: true, comment: [doGet()])
    _seq("B", "C", comment: [getAttribute ("user")])
    _seq("C", "B", comment: [return user])
    _seq("B", "C", comment: [getUserTracks (user)])
    _seq("C", "B", comment: [return userTracks])
    _seq("B", "E", enable-dst: true, comment: [toJson (userTracks)])
    _seq("E", "B", disable-src: true, comment: [return userTracks[JSON]])
    _seq("B", "A", disable-src: true, comment: [userTracks])
  }),
  comment: [
    As the name implies, this servlet retrieves all the Tracks associated to a User. This is fetched as usually from the session.

    Similar to the previous sequences, once it retrieves the track from the database, the list is transformed into a JSON by Gson and finally sent to the browser.
  ],
  label_: "get-user-tracks-sequence",
  comment_next_page_: false,
)

// VERY MUCH RIA SPECIFIC

#seq_diagram(
  [#ria() Event: Login],
  diagram({
    _par("A", display-name: "index.html")
    _par("B", display-name: [utils.ts + login.ts])
    _par("E", display-name: [Login])
    _par("C", display-name: [UserDAO])
    _par("D", display-name: [homepage.html])

    _seq("A", "B", comment: [GET])
    _seq("A", "B", enable-dst: true, comment: [Login], lifeline-style: (fill: rgb("#3178C6")))
    _seq("B", "E", comment: [POST: Login])
    _seq("E", "C", comment: [checkUser()])
    _seq("C", "B", comment: [Response])
    _seq("B", "B", comment: [[Response.status != 200] ? error])
    _seq("B", "D", disable-src: true, comment: [Redirect])
  }),
  comment: [
    As the server is deployed the `index.html` request the associated Javascript files (we use Typescript, but it transplies to Javascript and that's what is imported in the HTML files). As they have been loaded thanks to the IIFE, the User is able to Login.

    Once the button has been clicked, Javascript performs a POST request -- always via the `makeCall()` function -- to the Login servlet, which, as seen in the Login sequence diagram (@login-sequence), checks if the User exists: if that's the case it returns a 200 OK and the User is redirected to the Homepage.

    If not, then a error div will appear above the Login button.
  ],
  label_: "ria-event-login-sequence",
  comment_next_page_: false,
)

#seq_diagram(
  [#ria() Event: Register],
  diagram({
    _par("A", display-name: "index.html")
    _par("B", display-name: [utils.ts])
    _par("D", display-name: [register.html + register.ts])
    _par("E", display-name: [Register])
    _par("C", display-name: [UserDAO])

    _seq("A", "B", comment: [GET])
    _seq("A", "B", enable-dst: true, comment: [register()], lifeline-style: (fill: rgb("#3178C6")))
    _seq("B", "D", comment: [Redirect])
    _seq("D", "E", comment: [Register])
    _seq("E", "C", comment: [addUser()])
    _seq("C", "B", comment: [Response])
    _seq("B", "D", comment: [[response.status != 200] ? error])
    _seq("B", "A", disable-src: true, comment: [Redirect])
  }),
  comment: [
    Instead of logging in, the User may want to register: probably because there they have no account. If that's the case, after the Javascript files will have been fetched, the User will be redirect to the `register.html` page.

    From here, as seen in the Register sequence (@register-sequence), the servlet adds the User: if that's successful, then there will the redirect to the `index.html`; if not, an error message will appear above the Register button.
  ],
  label_: "ria-event-register-sequence",
  comment_next_page_: false,
)

#seq_diagram(
  [#ria() Event: Logout],
  diagram({
    _par("A", display-name: "home_page.html")
    _par("B", display-name: [homepage.ts])
    _par("C", display-name: [Logout])
    _par("D", display-name: [index.html])

    _seq("A", "B", comment: [GET])
    _seq("A", "B", enable-dst: true, comment: [Logout], lifeline-style: (fill: rgb("#3178C6")))
    _seq("B", "C", comment: [GET])
    _seq("C", "B", comment: [response])
    _seq("B", "D", disable-src: true, comment: [[response.status == 200] ? Redirect])
  }),
  comment: [
    The User is able to logout every moment after the Login. As the Logout button is pressed, Javascript performs a GET request to the Logout servlet: it responds with 200 OK if the session has been invalidated; else nothing will happen.
  ],
  label_: "ria-event-logout-sequence",
  comment_next_page_: false,
)

#seq_diagram(
  [#ria() Event: Access HomeView],
  diagram({
    _par("A", display-name: "home_page.html +
      homepage.ts")
    _par("B", display-name: "HomeView")
    _par("C", display-name: "HomePage")
    _par("D", display-name: "PlaylistDAO")

    _seq("A", "B", enable-dst: true, comment: [homeView.show()])
    _seq("B", "B", comment: [clearModals()])
    _seq("B", "B", comment: [clearBottomNavBar()])
    _seq("B", "B", comment: [loadCreatePlaylistModal()])
    _seq("B", "B", comment: [loadUploadTrackModal()])
    _seq("B", "B", comment: [loadButtons()])
    _seq("B", "B", enable-dst: true, comment: [loadPlaylists()])
    _seq("B", "B", comment: [cleanMain()])
    _seq(
      "B",
      "C",
      enable-dst: true,
      comment: [AJAX GET],
      lifeline-style: (fill: rgb("#3178C6")),
    )
    _seq("C", "D", enable-dst: true, comment: [getUserPlaylists(user)])
    _seq("D", "C", disable-src: true, comment: [playlists])
    _seq("C", "B", disable-src: true, comment: [playlists])
    _seq("B", "B", comment: [[req.status == 200]? \ playlistGrid(playlists)])
    _seq("B", "B", comment: [[else] alert(...)])
    _seq("B", "B", disable-src: true)
    _seq("B", "A", disable-src: true)
  }),
  comment: [
    The user can access the home view when the `home_page.html` first loads or after pressing the Homepage button in the sidebar.
    The view is loaded by calling the `show` method of the `HomeView` object, which clears the possibly remaining elements left by other views and loads the modals, buttons, playlists and event listeners associated to them.
  ],
  label_: "ria-event-logout-sequence",
  comment_next_page_: false,
)

#seq_diagram(
  [#ria() Event: Access PlaylistView],
  diagram({
    _par("A", display-name: "home_page.html +
      homepage.ts")
    _par("B", display-name: "PlaylistView")
    _par("C", display-name: "Playlist")
    _par("D", display-name: "PlaylistDAO")

    _seq("A", "B", enable-dst: true, comment: [playlistView.show(playlist)])
    _seq("B", "B", comment: [clearBottomNavBar()])
    _seq("B", "B", comment: [clearModals()])
    _seq("B", "B", comment: [loadAddTracksModal()])
    _seq("B", "B", comment: [loadPlaylistView(playlist)])
    _seq("B", "B", enable-dst: true, comment: [loadPlaylistTracks()])
    _seq("B", "B", comment: [cleanMain()])
    _seq("B", "C", enable-dst: true, comment: [AJAX GET \ /Playlist?\ playlistId=playlist.id])
    _seq("C", "D", enable-dst: true, comment: [getPlaylistTracksById(playlistId)])
    _seq("D", "C", disable-src: true, comment: [playlistTracks])
    _seq("C", "B", disable-src: true, comment: [playlistTracks])
    _seq("B", "B", comment: [[req.status == 200]? \ trackGrid(playlistTracks) \ loadPrevNextButtons()])
    _seq("B", "B", comment: [[else] alert(...)])
    _seq("B", "B", disable-src: true)
    _seq("B", "A", disable-src: true)
  }),
  comment: [
    The user can access the playlist view by selecting a playlist in the home view or by pressing the Playlist button in the sidebar, which will open the last visited playlist.
    The view is loaded by calling the `show` method of the `PlaylistView` object, which clears the elements from other views and loads the modal, buttons, tracks and event listeners associated to them.
  ],
  label_: "ria-event-logout-sequence",
  comment_next_page_: false,
)

#seq_diagram(
  [#ria() Event: Access TrackView],
  diagram({
    _par("A", display-name: "home_page.html +
      homepage.ts")
    _par("B", display-name: "TrackView")
    _par("C", display-name: "Track")
    _par("D", display-name: "TrackDAO")

    _seq("A", "B", enable-dst: true, comment: [trackView.show(track)])
    _seq("B", "B", comment: [clearModals()])
    _seq("B", "B", comment: [clearBottomNavBar()])
    _seq("B", "B", enable-dst: true, comment: [loadSingleTrack(track)])
    _seq("B", "B", comment: [cleanMain()])
    _seq("B", "C", enable-dst: true, comment: [AJAX GET \ /Track?\ track_id=track.id])
    _seq("C", "D", enable-dst: true, comment: [getTrackById(track_id)])
    _seq("D", "C", disable-src: true, comment: [track])
    _seq("C", "B", disable-src: true, comment: [track])
    _seq("B", "B", comment: [[req.status == 200]? trackPlayer(track)])
    _seq("B", "B", comment: [[else] alert(...)])
    _seq("B", "B", disable-src: true)
    _seq("B", "A", disable-src: true)
  }),
  comment: [
    The user can access the track view by selecting a track in the playlist view or by pressing the Track button in the sidebar, which will open the last visted track.
    The view is loaded by calling the `show` method of the `TrackView` object, which clears the elements from other views and loads the player and the song details.
  ],
  label_: "ria-event-logout-sequence",
  comment_next_page_: false,
)

#seq_diagram(
  [#ria() Event: Upload Track modal],
  diagram({
    _par("A", display-name: "HomeView")
    _par("B", display-name: "MainLoader")
    _par("D", display-name: "utils.ts")
    _par("C", display-name: "UploadTrack modal")
    _par("F", display-name: "UploadTrack")

    _seq("A", "B", enable-dst: true, comment: [click()])
    _seq("B", "B", comment: [loadYears()])
    _seq(
      "B",
      "D",
      enable-dst: true,
      comment: [loadGenres()],
      lifeline-style: (fill: rgb("#3178C6")),
    )
    _seq(
      "D",
      "D",
      comment: [
        AJAX GET \
        genres.json
      ],
    )
    _seq(
      "D",
      "D",
      comment: [
        [req.status == 200] ? \
        append genres to \
        genre-selection
      ],
    )
    _seq("D", "B", disable-src: true)
    _seq("B", "C", disable-src: true, enable-dst: true, comment: [showModal (upload-track)])
    _seq("C", "C", comment: [upload-track-btn.click()])
    _seq(
      "C",
      "F",
      enable-dst: true,
      comment: [
        AJAX POST \
        form
      ],
      lifeline-style: (fill: rgb("#3178C6")),
    )
    _seq(
      "F",
      "C",
      disable-src: true,
      comment: [response],
    )
    _seq(
      "C",
      "C",
      comment: [
        [req.status == 201] \
        ? success : error
      ],
    )
    _seq("C", "A", disable-src: true, comment: [modal-close.click()])
  }),
  comment: [
    As the User logs in, in order to being able to listen the tracks, they must be uploaded. From the top nav bar, in the HomeView, there is the corresponding button.

    After the click event, the MainLoader calls the `loadYears()`, `loadGenres()` and finally the `showModal()` functions. From there, the User is able to create new tracks by inserting the necessary metadata: title, artist, album, year, genre, image and file path (these are the same as seen in the Upload track sequence, see @uploadtrack-sequence -- that's why they are omitted).

    If the operation is successful, a div with "Success" is shown; otherwise error. Finally the User can close and modal and return to the HomeView.
  ],
  label_: "upload-track-modal-sequence",
  comment_next_page_: false,
)

#seq_diagram(
  [#ria() Event: Reorder modal],
  diagram({
    _par("B", display-name: "HomeView")
    _par("A", display-name: "MainLoader")
    _par("C", display-name: "ReorderTrack modal")
    _par("D", display-name: "homepage.ts")
    _par("E", display-name: "Playlist")
    _par("F", display-name: "TrackReoder")

    _seq("B", "A", comment: [click()])
    _seq("A", "C", enable-dst: true, comment: [loadReorderModal()])
    _seq(
      "C",
      "D",
      enable-dst: true,
      comment: [
        loadUserTracksOl (\
        trackSelector,\
        playlist)
      ],
      lifeline-style: (fill: rgb("#3178C6")),
    )
    _seq("D", "E", enable-dst: true, comment: [AJAX GET \ Playlist? \ playlistId=playlist.id])
    _seq("E", "D", disable-src: true, comment: [tracks])
    _seq("D", "D", comment: [[req.status == 200] ? \ add tracks to selector])
    _seq("D", "D", comment: [[else] alert(...)])
    _seq("D", "C", disable-src: true)
    _seq(
      "C",
      "D",
      enable-dst: true,
      comment: [saveOrder (e, \
        playlistId)
      ],
      lifeline-style: (fill: rgb("#3178C6")),
    )
    _seq(
      "D",
      "F",
      enable-dst: true,
      comment: [
        AJAX POST \
        requestData:\
        {trackIds,playlistId}
      ],
    )
    _seq(
      "F",
      "D",
      disable-src: true,
      comment: [
        [req.status == 201] \
        ? success : error
      ],
    )
    _seq("D", "C", disable-src: true)
    _seq("C", "B", disable-src: true, comment: [closeReorderModal()])
  }),
  comment: [
    // This modal is responible for adding a custom order to the added tracks in a playlist. From the HomeView, every playlist has a reorder button thats open the corresponding modal.

    This modal is quite different from the upload tracks modal becuase, in that case, the User must see the tracks that are _not_ in that playlist, however if they are to be reordered, the User has to see them all. And being able to drag and drop them: that's why the `loadUserTracksOl()` function is called -- `ol` stands for _Ordered List_. The logic is very similary to the regular `loadUserTracks()`.

    After being satisfied with the new order, the User clicks on the save oreder button that POSTS a JSON-formatted object to Java -- the only function in the project to do so.

    If the operation is successful, a div with "Success" is shown; otherwise error. Finally the User can close and modal and return to the HomeView.
  ],
  label_: "reorder-modal-sequence",
  comment_next_page_: false,
)
#seq_diagram(
  [#ria() Event: Create Playlist modal],
  diagram({
    _par("B", display-name: "HomeView")
    _par("C", display-name: "create-playlist modal")
    _par("D", display-name: "homepage.ts")
    _par("E", display-name: "CreatePlaylist")

    _seq("B", "C", comment: [click()])
    // _seq("A", "C", enable-dst: true, comment: [loadCreatePlaylistModal()])
    _seq(
      "C",
      "D",
      enable-dst: true,
      comment: [create-playlist-btn.click()],
      lifeline-style: (fill: rgb("#3178C6")),
    )
    _seq(
      "D",
      "F",
      enable-dst: true,
      comment: [
        AJAX POST \
        form
      ],
    )
    _seq(
      "F",
      "D",
      disable-src: true,
      comment: [
        [req.status == 201] \
        ? success : error
      ],
    )
    _seq("D", "C", disable-src: true)
    _seq("C", "B", disable-src: true, comment: [modal-close.click()])
  }),
  comment: [
    The User is able to create playlists by clicking on the corresponding button in the top navigation bar. Then, the User must insert the required data, which is only the title (as seen in @createplaylist-sequence); there is no way to add already uploaded tracks -- it can only be done via the the modal (@add-track-modal-sequence).

    Once satisfied, the User can click on the button in bottom part of the modal to save the updates.

    If the operation is successful, a div with "Playlist created successfully" is shown; otherwise error. Finally the User can close and modal and return to the HomeView.
  ],
  label_: "create-playlist-modal-sequence",
  comment_next_page_: false,
)

#seq_diagram(
  [#ria() Event: Add Track modal],
  diagram({
    _par("A", display-name: "home_page.html +
      homepage.ts")
    _par("B", display-name: "modal button")
    _par("C", display-name: "utils.ts")
    _par("D", display-name: "GetTracksNotInPlaylist")

    _seq("A", "B", enable-dst: true, comment: [click])
    _seq(
      "B",
      "C",
      enable-dst: true,
      comment: [loadUserTracks \ (trackSelector, playlist)],
      lifeline-style: (fill: rgb("#3178C6")),
    )
    _seq("C", "D", enable-dst: true, comment: [AJAX GET \ GetTracksNotInPlaylist? \ playlistTitle= playlist.title])
    _seq("D", "C", disable-src: true, comment: [tracks])
    _seq("C", "C", comment: [[req.status == 200]? \ add tracks to selector])
    _seq("C", "C", comment: [[else] alert(...)])
    _seq("C", "B", disable-src: true)
    _seq("B", "C", comment: [showModal(modal)])
    _seq("B", "B", disable-src: true)
  }),
  comment: [
    The User can access the add-tracks modal by pressing the Add Tracks button in the playlist view.
    The click event listener on the button gets the user tracks not already added to the playlist from the server, adds them to the track selector and then makes the modal visible.
  ],
  label_: "add-track-modal-sequence",
  comment_next_page_: false,
)
