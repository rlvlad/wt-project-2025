(function () {
    let lastPlaylist: Playlist = null, lastTrack: Track = null;
    const HOMEPAGE_LABEL: string = "All Playlists";
    window.onload = function () {
        // close modals
        location.hash = "#";

        // loading
        loadPlaylists();


        document.getElementById("logout-button").addEventListener("click", () => {
            makeCall("GET", "Logout", null, (req: XMLHttpRequest) => {
                if (req.readyState == XMLHttpRequest.DONE) {
                    if (req.status == 200) {
                        location.href = "index.html";
                    }
                }
            });
        });

        // add listeners on sidebar buttons
        document.getElementById("homepage-button").addEventListener("click", function () {
            loadPlaylists();
        });

        document.getElementById("playlist-button").addEventListener("click", function () {
            if (lastPlaylist != null) {
                loadPlaylistTracks(lastPlaylist);
            }
        });

        document.getElementById("track-button").addEventListener("click", function () {
            if (lastTrack != null) {
                loadSingleTrack(lastTrack);
            }
        });

        // load modal data when clicking on the modal
        document.getElementById("upload-track-modal-button").addEventListener("click", function () {
            loadYears();
            loadGenres();
        });

        document.getElementById("add-playlist-modal-button").addEventListener("click", () => {
            loadUserTracks(document.getElementById("track-selector"))
        });

        // Even if no submit button is present, forms with a single implicit submission blocking field still submit when the Enter key is pressed
        // https://html.spec.whatwg.org/multipage/form-control-infrastructure.html#implicit-submission
        document.getElementById("create-playlist").getElementsByTagName("form").item(0).addEventListener("submit", (e) => {
            e.preventDefault();
        });

        // update homepage with new playlist
        document.getElementById("create-playlist-btn").addEventListener("click", function () {
            let self: HTMLElement = this;
            let form: HTMLFormElement = this.closest("form");

            if (form.checkValidity()) {
                makeCall("POST", "CreatePlaylist", form, function (req: XMLHttpRequest) {
                    if (req.readyState == XMLHttpRequest.DONE) {
                        let message: string = req.responseText;
                        switch (req.status) {
                            case 201:
                                let newPlaylist: Playlist = JSON.parse(message);
                                let itemsContainer: HTMLElement = document.querySelector(".items-container");
                                if (document.getElementsByClassName("main-label").item(0).textContent == HOMEPAGE_LABEL)
                                    itemsContainer.insertBefore(createPlaylistButton(newPlaylist), itemsContainer.firstChild);

                                self.parentElement.previousElementSibling.setAttribute("class", "success");
                                self.parentElement.previousElementSibling.textContent = "Playlist created successfully";
                                form.reset();
                                break;
                            case 409:
                                self.parentElement.previousElementSibling.setAttribute("class", "error");
                                self.parentElement.previousElementSibling.textContent = message;
                                break;
                        }
                    }
                }, false);
            } else {
                form.reportValidity();
            }
        });

        document.getElementById("upload-track-btn").addEventListener("click", function () {
            let self: HTMLElement = this;
            let form: HTMLFormElement = this.closest("form");

            if (form.checkValidity()) {
                makeCall("POST", "UploadTrack", this.closest("form"), function (req: XMLHttpRequest) {
                    let message: string = req.responseText;

                    if (req.readyState == XMLHttpRequest.DONE) {
                        switch (req.status) {
                            case 201:
                                self.parentElement.previousElementSibling.setAttribute("class", "success");
                                self.parentElement.previousElementSibling.textContent = "Track uploaded successfully";
                                form.getElementsByTagName("input").item(0).value = "";
                                (document.getElementById("musicTrack") as HTMLInputElement).value = "";
                                break;
                            case 409:
                                self.parentElement.previousElementSibling.setAttribute("class", "error");
                                self.parentElement.previousElementSibling.textContent = message;
                        }

                    }
                }, false);
            } else {
                form.reportValidity();
            }
        })
    }

    // Helpers methods

    /**
     * Delete everything from main div.
     */
    function cleanMain() {
        let main_div: HTMLElement = document.getElementById("main");
        main_div.innerHTML = "";
    }

    // Main loaders

    /**
     * Load the Playlists.
     *
     * @param playlists array of Playlists
     */
    function playlistGrid(playlists: Playlist[]) {
        let main: HTMLElement = document.getElementById("main");
        let container: HTMLElement = document.createElement("div");
        container.setAttribute("class", "items-container");
        main.appendChild(container);

        playlists.forEach(function (playlist: Playlist) {
            container.appendChild(createPlaylistButton(playlist));
        })
    }

    /**
     * Load the Tracks of a Playlist.
     *
     * @param tracks array of Tracks
     */
    function trackGrid(tracks: Track[]) {
        let button: HTMLButtonElement, text: HTMLSpanElement, span_1: HTMLSpanElement,
            span_2: HTMLSpanElement, image: HTMLImageElement;
        let main: HTMLElement = document.getElementById("main");
        let container: HTMLElement = document.createElement("div");
        container.setAttribute("class", "items-container");
        main.appendChild(container);

        tracks.forEach(function (track: Track) {
            button = document.createElement("button");
            button.setAttribute("class", "single-item song-button");
            button.setAttribute("name", "playlistId");

            text = document.createElement("span");
            text.setAttribute("class", "text-container")

            span_1 = document.createElement("span");
            span_1.setAttribute("class", "first-line");
            span_1.textContent = track.title;

            span_2 = document.createElement("span");
            span_2.setAttribute("class", "second-line");
            span_2.textContent = track.album_title;

            image = document.createElement("img");
            image.setAttribute("class", "album-image");
            image.setAttribute("src", track.image_path)
            // image.setAttribute("alt", "Track player");
            image.setAttribute("width", "100");
            image.setAttribute("height", "100");

            button.addEventListener("click", () => {
                loadSingleTrack(track);
            });

            button.appendChild(text);
            text.appendChild(span_1);
            text.appendChild(document.createElement("br"));
            text.appendChild(span_2);
            button.appendChild(image);
            container.appendChild(button);
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

        let centerPanelContainer: HTMLDivElement = document.createElement("div");
        centerPanelContainer.setAttribute("class", "center-panel-container");

        let center_panel: HTMLElement = document.createElement("div");
        center_panel.setAttribute("class", "center-panel")

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
        // image.setAttribute("alt", "Track player");
        image.setAttribute("width", "200");
        image.setAttribute("height", "200");

        let audio_ctrl: HTMLAudioElement = document.createElement("audio");
        audio_ctrl.controls = true;

        let audio_src: HTMLSourceElement = document.createElement("source");
        audio_src.setAttribute("src", track.song_path);
        audio_src.setAttribute("type", "audio/mpeg");

        // track panel creation
        center_panel.appendChild(createTrack(track.artist));
        center_panel.appendChild(createTrack(track.album_title));
        center_panel.appendChild(createTrack(track.year.toString()));
        center_panel.appendChild(createTrack(track.genre));
        center_panel.appendChild(document.createElement("hr"));
        center_panel.appendChild(image);
        center_panel.appendChild(document.createElement("hr"));
        audio_ctrl.appendChild(audio_src);
        center_panel.appendChild(audio_ctrl);

        centerPanelContainer.appendChild(center_panel);
        container.appendChild(centerPanelContainer);

    }

    // Modal data loaders

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
        let option: HTMLOptionElement = document.createElement("option");
        option.setAttribute("value", "");
        option.textContent = "Genre";
        genre_selection.appendChild(option);

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

        let option: HTMLOptionElement = document.createElement("option");
        option.setAttribute("value", "");
        option.textContent = "Year";
        year_selection.appendChild(option);

        for (let i = today; i >= 1901; i--) {
            option = document.createElement("option");
            option.textContent = i.toString();
            year_selection.appendChild(option);
        }
    }

    // Single screens of the webapp

    /**
     * Loads the HomePage, that is all the Playlists.
     */
    function loadPlaylists() {
        cleanMain();
        document.getElementsByClassName("main-label").item(0).textContent = HOMEPAGE_LABEL;

        makeCall("GET", "HomePage", null,
            // callback function
            function (req: XMLHttpRequest) {
                if (req.readyState == XMLHttpRequest.DONE) { // == 4
                    let message: string = req.responseText;
                    if (req.status == 200) {
                        // parse JSON for user playlists
                        let playlists: Playlist[] = JSON.parse(message);

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
    function loadPlaylistTracks(playlist: Playlist) {
        cleanMain()
        document.getElementsByClassName("main-label").item(0).textContent = playlist.title;

        lastPlaylist = playlist;

        makeCall("GET", "Playlist?playlistId=" + playlist.id.toString(),
            null,
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
    function loadSingleTrack(track: Track) {
        // clean main div
        cleanMain();
        document.getElementsByClassName("main-label").item(0).textContent = track.title;

        lastTrack = track;

        makeCall("GET", "Track?track_id=" + track.id.toString(), null,
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
                        trackPlayer(document.getElementById("main"), track);
                    } else {
                        // request failed, handle it
                        // self.listcontainer.style.visibility = "hidden";
                        alert("Cannot recover data. Maybe the User has been logged out."); //for demo purposes
                    }
                }
            });
    }

    /**
     * Get user tracks and add them to the track selector parameter
     * @param trackSelector
     * @param playlist optional parameter used for loading only tracks not present in the specified playlist
     */
    function loadUserTracks(trackSelector: HTMLElement, playlist: Playlist = null) {
        trackSelector.innerHTML = "";

        makeCall("GET", "GetUserTracks", null, function (req: XMLHttpRequest) {
            if (req.readyState == XMLHttpRequest.DONE) {
                let message: string = req.responseText;
                if (req.status == 200) {
                    let tracks: Track[] = JSON.parse(message);
                    if (tracks.length === 0) {
                        let option: HTMLOptionElement = document.createElement("option");
                        option.value = "";
                        option.textContent = "There are no available tracks to be added."
                        trackSelector.setAttribute("size", "1");
                        trackSelector.appendChild(option);
                        return;
                    } else if (tracks.length < 10) {
                        trackSelector.setAttribute("size", tracks.length.toString());
                    }
                    tracks.forEach(function (track: Track) {
                        let option: HTMLOptionElement = document.createElement("option");
                        option.value = track.id.toString();
                        option.textContent = track.artist + " - " + track.title + " (" + track.year + ")"
                        trackSelector.appendChild(option);
                    });
                } else {
                    alert("Cannot recover data. Maybe the User has been logged out."); //for demo purposes
                }
            }
        });
    }

    /**
     * Creates and returns a button based on the playlist parameter
     * @param playlist
     */
    function createPlaylistButton(playlist: Playlist): HTMLButtonElement {
        let button = document.createElement("button");
        button.setAttribute("class", "single-item playlist-title");
        button.setAttribute("name", "playlistId");

        let span = document.createElement("span");
        span.setAttribute("class", "first-line");
        span.textContent = playlist.title;

        button.addEventListener("click", () => {
            loadPlaylistTracks(playlist);
        });

        button.appendChild(span);
        return button;
    }
})();