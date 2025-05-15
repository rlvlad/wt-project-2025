(function () {
    window.onload = function () {
        // loading
        loadPlaylists();
        loadYears();
        loadGenres();

        // add listeners on sidebar buttons
        document.getElementById("homepage-button").addEventListener("click", function () {
            loadPlaylists();
        })

        document.getElementById("playlist-button").addEventListener("click", function () {
            // loadPlaylistTracks();
            alert("Verrà caricata l'ultima playlist selezionata.")
        })

        document.getElementById("track-button").addEventListener("click", function () {
            // loadSingleTrack();
            alert("Verrà caricata l'ultima traccia selezionata.")
        })
    }

    /**
     * Delete everything from main div and appends to it the track container, used to hold both the Playlists
     * and the Tracks.
     */
    function cleanMain() {
        let main_div: HTMLElement = document.getElementById("main");
        main_div.innerHTML = "";
        let track_container: HTMLElement = document.createElement("div");
        track_container.setAttribute("id", "track-container");

        main_div.appendChild(track_container);
    }

    /**
     * Load the Playlists.
     *
     * @param playlists array of Playlists
     */
    function playlistGrid(playlists: Playlist[]) {
        let cell: HTMLFormElement, button: HTMLButtonElement, span: HTMLSpanElement;
        let container: HTMLElement = document.getElementById("track-container");
        container.innerHTML = "";

        playlists.forEach(function (playlist: Playlist) {
            cell = document.createElement("form");
            cell.setAttribute("onclick", "loadPlaylistTracks");
            cell.setAttribute("method", "GET");

            button = document.createElement("button");
            button.setAttribute("class", "single-item playlist-title");
            button.setAttribute("name", "playlistId");
            button.setAttribute("value", playlist.id.toString());

            span = document.createElement("span");
            span.setAttribute("class", "first-line");
            span.textContent = playlist.title;

            button.appendChild(span);
            cell.appendChild(button);
            container.appendChild(cell);
        })
    }

    /**
     * Load the Tracks of a Playlist.
     *
     * @param tracks array of Tracks
     */
    function trackGrid(tracks: Track[]) {
        let cell: HTMLFormElement, button: HTMLButtonElement, span_1: HTMLSpanElement, span_2: HTMLSpanElement,
            image: HTMLImageElement;
        let container: HTMLElement = document.getElementById("track-container");
        container.innerHTML = "";

        tracks.forEach(function (track: Track) {
            cell = document.createElement("form");
            cell.setAttribute("action", "Track"); // TODO fix the action
            cell.setAttribute("method", "GET");

            button = document.createElement("button");
            button.setAttribute("class", "single-item song-button");
            button.setAttribute("name", "playlistId");
            button.setAttribute("value", track.id.toString());

            span_1 = document.createElement("span");
            span_1.setAttribute("class", "first-line");
            span_1.textContent = track.title;

            span_1 = document.createElement("span");
            span_1.setAttribute("class", "second-line");
            span_1.textContent = track.album_title;

            image = document.createElement("img");
            image.setAttribute("class", "album-image");
            image.setAttribute("src", track.image_path)
            image.setAttribute("alt", "Track player");
            image.setAttribute("width", "100");
            image.setAttribute("height", "100");

            button.appendChild(span_1);
            button.appendChild(span_2);
            button.appendChild(image);
            cell.appendChild(button);
            container.appendChild(cell);
        })
    }

    /**
     * Load the Track player. Unlike the other loaders, it's only a center panel.
     *
     * @param container container in which load the Track player
     * @param track Track to load
     */
    function trackPlayer(container: HTMLElement, track: Track) {
        container.innerHTML = "";

        let center_panel: HTMLElement = document.createElement("div");

        let track_metadata: HTMLElement;

        /**
         * Returns a Track metadata div.
         *
         * @param track_property attribute to set as text, textContent
         * @return div of class "track-metadata"
         */
        function createTrack(track_property: string) {
            track_metadata = document.createElement("div");
            track_metadata.setAttribute("class", "track-metadata");

            track_metadata.setAttribute("text", track_property);
            track_metadata.textContent = track_property;

            return track_metadata;
        }

        let image: HTMLImageElement = document.createElement("img");
        image.setAttribute("src", track.image_path);
        image.setAttribute("alt", "Track player");
        image.setAttribute("width", "200");
        image.setAttribute("height", "100");

        let audio_ctrl: HTMLAudioElement = document.createElement("audio");
        audio_ctrl.setAttribute("controls", ""); // TODO rivedere

        let audio_src: HTMLSourceElement = document.createElement("source");
        audio_src.setAttribute("src", track.song_path);
        audio_src.setAttribute("type", "audio/mpeg");

        // track panel creation
        center_panel.appendChild(createTrack(track.artist));
        center_panel.appendChild(createTrack(track.album_title));
        center_panel.appendChild(createTrack(track.year.toString()));
        center_panel.appendChild(createTrack(track.genre));
        center_panel.appendChild(document.createElement("<hr>"));
        center_panel.appendChild(image);
        center_panel.appendChild(document.createElement("<hr>"));
        audio_ctrl.appendChild(audio_src);
        center_panel.appendChild(audio_src);
    }

    // Modal loaders

    /**
     * Loads the musical genres for upload track modal.
     */
    function loadGenres() {
        let genres: string[] = [
            "Classical",
            "Rock",
            "Edm",
            "Pop",
            "Hip-hop",
            "R&B",
            "Country",
            "Jazz",
            "Blues",
            "Metal",
            "Folk",
            "Soul",
            "Funk",
            "Electronic",
            "Indie",
            "Reggae",
            "Disco"
        ];

        let genre_selection: HTMLElement = document.getElementById("genre-selection");
        genre_selection.innerHTML = "";
        let option: HTMLOptionElement;

        genres.forEach(function (genre: string) {
            option = document.createElement("option");
            option.textContent = genre;
            genre_selection.appendChild(option);
        })
    }

    /**
     * Loads year from 1900 to the current one for upload track modal.
     */
    function loadYears() {
        let today: number = new Date().getFullYear();
        let year_selection = document.getElementById("year-selection");
        year_selection.innerHTML = "";
        let option: HTMLOptionElement;

        for (let i = 1900; i <= today; i++) {
            option = document.createElement("option");
            option.textContent = i.toString();
            year_selection.appendChild(option);
        }
    }

    function openSideBar() {
        document.getElementById("side-bar").style.display = "block";
    }

    // Single parts of the webapp

    /**
     * Loads the HomePage, that is all the Playlists.
     */
    function loadPlaylists() {
        cleanMain();

        makeCall("GET", "HomePage", null,
            // callback function
            function (req: XMLHttpRequest) {
                if (req.readyState == XMLHttpRequest.DONE) { // == 4
                    let message: string = req.responseText;
                    if (req.status == 200) {
                        // parse JSON for user playlists
                        let playlists: Playlist[] = JSON.parse(message);

                        if (playlists.length === 0) {
                            alert("The User has no playlists.");
                            return;
                        }

                        // pass the JSON of all Playlists
                        playlistGrid(playlists);
                    } else {
                        // request failed, handle it
                        // self.listcontainer.style.visibility = "hidden";
                        alert("Cannot recover data. Maybe the User has been logged out."); //for demo purposes
                    }
                }
            });
    }

    /**
     * Load all the Tracks associated to a Playlist.
     */
    function loadPlaylistTracks() {
        cleanMain()

        makeCall("GET", "Playlist", null,
            // callback function
            function (req: XMLHttpRequest) {
                if (req.readyState == XMLHttpRequest.DONE) { // == 4
                    let message: string = req.responseText;
                    if (req.status == 200) {
                        // parse JSON for user tracks
                        let tracks: Track[] = JSON.parse(message);

                        if (tracks.length === 0) {
                            alert("This Playlist has no Tracks.");
                            return;
                        }

                        // pass the JSON of all Tracks
                        trackGrid(tracks);
                    } else {
                        // request failed, handle it
                        // self.listcontainer.style.visibility = "hidden";
                        alert("Cannot recover data. Maybe the User has been logged out."); //for demo purposes
                    }
                }
            });
    }

    /**
     * Load a single Track from a Playlist.
     */
    function loadSingleTrack() {
        // clean main div
        let main_div: HTMLElement = document.getElementById("main");
        main_div.innerHTML = "";

        makeCall("GET", "Track", null,
            // callback function
            function (req: XMLHttpRequest) {
                if (req.readyState == XMLHttpRequest.DONE) { // == 4
                    let message: string = req.responseText;
                    if (req.status == 200) {
                        // parse JSON for user tracks
                        let track: Track = JSON.parse(message);

                        if (track === null) {
                            alert("This Track can't be played.");
                            return;
                        }

                        // pass the JSON of all Tracks
                        trackPlayer(main_div, track);
                    } else {
                        // request failed, handle it
                        // self.listcontainer.style.visibility = "hidden";
                        alert("Cannot recover data. Maybe the User has been logged out."); //for demo purposes
                    }
                }
            });
    }
})();