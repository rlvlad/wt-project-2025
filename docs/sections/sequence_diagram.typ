#import "../lib.typ": *
// #show: project.with()

= Sequence diagrams

#seq_diagram(
  "Login sequence diagram",
  diagram({
    _par("A", display-name: "Client")
    _par("B", display-name: "Login")
    _par("D", display-name: "UserDAO")
    _par("C", display-name: "Thymeleaf", shape: "custom", custom-image: thymeleaf)
    _par("E", display-name: "Session")
    _par("F", display-name: "HomePage")

    _seq("A", "B", enable-dst: true, comment: "doGet()")
    _seq("B", "C", enable-dst: true, comment: "process(index.html, WebContext)")
    _seq("C", "B", disable-src: true, comment: "index.html")
    _seq("B", "A", disable-src: true, comment: "index.html")
    _seq("A", "B", enable-dst: true, comment: "doPost()")
    _seq("B", "D", enable-dst: true, comment: "checkUser()")
    _seq("D", "B", disable-src: true, comment: "return schrödingerUser")
    _seq("B", "B", comment: "[schrödingerUser == null] ? redirect")
    _seq("B", "E", comment: "[schrödingerUser != null] ? setAttribute(\"user\", schrödingerUser)")
    _seq("B", "F", disable-src: true, comment: "Redirect")
  }),
  comment: [
    Once the server is up and running, the Client requests the Login page. Then, thymeleaf processes the request and returns the correct context, to index the chosen locale.\
    Afterwards, the User inserts their credentials.

    Those values are passed to the `checkUser()` function that returns `schrödingerUser` -- as the name implies, the variable might return a User; otherwise `null`. If `null`, then the credentials inserted do not match any record in the database; else the User is redirected to their HomePage and the `user` variable is set for the current session.
  ],
  label_: "login-sequence",
)

#seq_diagram(
  [Register sequence diagram],
  diagram({
    _par("A", display-name: "Client")
    _par("B", display-name: "Register")
    _par("C", display-name: "Thymeleaf", shape: "custom", custom-image: thymeleaf)
    _par("D", display-name: "UserDAO")
    _par("G", display-name: "WebContext")
    _par("E", display-name: "Session")
    _par("F", display-name: "Login")

    _seq("A", "B", enable-dst: true, comment: "doGet()")
    _seq("B", "C", enable-dst: true, comment: "process(register.html, WebContext)")
    _seq("C", "B", disable-src: true, comment: "register.html")
    _seq("B", "A", disable-src: true, comment: "register.html")

    _seq("A", "B", enable-dst: true, comment: "doPost()")
    _seq("B", "D", enable-dst: true, comment: "addUser()")
    _seq("D", "B", disable-src: true, comment: "return isUserAdded")
    _seq("B", "F", comment: "[isUserAdded] ? redirect")
    _seq("B", "G", comment: [[!isUserAdded] ? redirect `/Registration?isUserAdded=false`])
    _seq("B", "C", enable-dst: true, comment: "process(register.html, WebContext)")
    _seq("C", "B", disable-src: true, comment: "register.html")
    _seq("B", "A", disable-src: true, comment: "register.html")
  }),
  comment: [
    If the User is not yet registered, they might want to create an account. If that's the case, as per the Login sequence diagram, initially thymeleaf processes the correct context, then the User inserts the credentials.

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
    _par("D", display-name: "WebContext")
    _par("E", display-name: "Thymeleaf", shape: "custom", custom-image: thymeleaf)

    _seq("A", "B", enable-dst: true, comment: "doGet()")
    _seq("B", "F", enable-dst: true, comment: [getAttribute("user")])
    _seq("F", "B", disable-src: true, comment: [return user])
    _seq("B", "C", enable-dst: true, comment: "getUserPlaylists(user)")
    _seq("C", "B", disable-src: true, comment: "return Playlists")
    _seq("B", "D", comment: [setVariable("playlists", Playlists)])
    _seq("B", "E", enable-dst: true, comment: "process(home_page, WebContext)")
    _seq("E", "B", disable-src: true, comment: "home_page.html")
    _seq("B", "A", disable-src: true, comment: "home_page.html")
  }),
  comment: [
    Once the Login is complete, the User is redirected to their HomePage, which hosts all their Playlists. In order to do so, the program needs to User attribute -- which is retrieved via the session; then, it is passed to the `getUserPlaylists` function and finally thymeleaf displays all values.
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
    _par("D", display-name: "WebContext")
    _par("E", display-name: "Thymeleaf", shape: "custom", custom-image: thymeleaf)

    _seq("A", "B", enable-dst: true, comment: "doGet()")
    _seq("B", "F", enable-dst: true, comment: [getAttribute("user")])
    _seq("F", "B", disable-src: true, comment: [return user])
    _seq("B", "G", enable-dst: true, comment: [getParameter("playlist_title")])
    _seq("G", "B", disable-src: true, comment: [return playlistTitle])
    _seq("B", "C", enable-dst: true, comment: "getPlaylistTracks(playlistTitle, user)")
    _seq("C", "B", disable-src: true, comment: "return Playlists")
    _seq("B", "D", comment: [setVariable("playlistsTitle", playlistTitle)])
    _seq("B", "D", comment: [setVariable("playlistTracks", playlistTracks)])
    _seq("B", "E", enable-dst: true, comment: "process(playlist_page, WebContext)")
    _seq("E", "B", disable-src: true, comment: "playlist_page.html")
    _seq("B", "A", disable-src: true, comment: "playlist_page.html")
  }),
  comment: [
    From the HomePage, the User is able to see all their playlists. By clicking on either one of them, the program redirects to the corresponding PlaylistPage, which lists all the tracks associated to that playlist.

    In order to do so, the program needs the User attribute -- which is retrieved via the session -- and the title of the playlists, which is given as a parameter by pressing the corresponding button in HomePage.

    Then those value are passed to `getPlaylistTracks()`, that returns all the tracks. Finally, thymeleaf processes the context and display all the tracks.
  ],
  label_: "playlistpage-sequence",
)

#seq_diagram(
  [Track sequence diagram],
  diagram({
    _par("A", display-name: "Client")
    _par("B", display-name: "Track")
    _par("G", display-name: "Request")
    _par("C", display-name: "TrackDAO")
    _par("D", display-name: "WebContext")
    _par("E", display-name: "Thymeleaf", shape: "custom", custom-image: thymeleaf)

    _seq("A", "B", enable-dst: true, comment: "doGet()")
    _seq("B", "G", enable-dst: true, comment: [getParameter("track_id")])
    _seq("G", "B", disable-src: true, comment: [return trackId])
    _seq("B", "C", enable-dst: true, comment: "getTrackById(trackId)")
    _seq("C", "B", disable-src: true, comment: "return track")
    _seq("B", "D", comment: [setVariable("track", track)])
    _seq("B", "E", enable-dst: true, comment: "process(player_page, WebContext)")
    _seq("E", "B", disable-src: true, comment: "player_page.html")
    _seq("B", "A", disable-src: true, comment: "player_page.html")
  }),
  comment: [
    Once the program has lodead all the tracks associated to a playlist, it allows to play them one by one in the dedicated player page. In a similar fashion to the `getPlaylistTracks()` method, in order to retrieve all the information regarding a single track the program is given the `track_id` parameter by pressing the corresponding button.

    Finally, `getTrackById()` returns the track metadata, thymeleaf processes the context and displays all the information.
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
    _note("right", [POST /UploadTrack \ title, artist, album, \ year, genre, \ musicTrack, image])
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
          comment: [newFiles.add(outputFile) \ relativeFilePath=relativeOutputFolder+"/" \ +mimetype+outputFile.getName()],
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
    The user can upload tracks from the appropriate form in the homepage. When the POST request is received, the request parameters are checked for null values and emptiness (omitted in the diagram for the sake of simplicity), and the uploaded files are written to disk by the processPart method, which has two parameters: a Part object, which "represents a part or form item that was received within a multipart/form-data POST request" @part, and its expected MIME type. The latter does not need to be fully specified (i.e. the subtype can be omitted). Before writing the file to disk, the method checks for duplicates of the file by calculating its SHA256 hash and querying the database with the isTrackFileAlreadyPresent and isImageFileAlreadyPresent methods present in TrackDAO. These two methods return the relative file path corresponding to the file hash if a matching one is found, otherwise null is returned; in the former case, processPart returns the found path and the new track is uploaded using the already present file, managing to avoid creating duplicates, in the latter case processPart proceeds by writing the file to disk and returning the new file's path. To write the file to the correct path in the webapp folder (realOutputFolder), context.getRealPath(relativeOutputFolder) is called, where relativeOutputFolder is obtained from the web.xml and is, in our case, "uploads"; realOutputFolder is obtained by appending, with the appropriate separators, the MIME type to the result of getRealPath; to get realOutputFilePath, a random UUID and the filename are appended to realOutputFolder. Having obtained the desired path, the file can be created and then written with the Files.copy method. Lastly, processPart adds the new file to the newFiles list in UploadTrack and returns the path relative to the webapp folder because that's where the application will be looking when its has to retrieve files. With this done, the new Track object is created and passed to the addTrack method of TrackDAO; if an SQLException is thrown, all the files in newFiles list are deleted and then, in the finally block, the list is cleared.
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
    _seq("B", "E", comment: [addTracksToPlaylist(playlistId,selectedTracksIds)])
    _seq("B", "D", disable-src: true, comment: [Redirect])
  }),
  label_: "createplaylist-sequence",
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
)
