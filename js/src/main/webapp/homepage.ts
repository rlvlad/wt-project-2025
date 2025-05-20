(function () {
    const HOMEPAGE_LABEL: string = "All Playlists";
    const HOMEPAGE_ID: string = "homepage", PLAYLIST_PAGE_ID: string = "playlist", PLAYER_PAGE_ID: string = "player";
    let lastPlaylist: Playlist = null, lastTrack: Track = null;
    let tracklist: Track[], trackGroup = 0;
    let homepage = new HomePage(), playlistPage = new PlaylistPage(), playerPage = new PlayerPage();

    window.onload = function () {
        // loading
        homepage.show();

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
            homepage.show();
        });

        document.getElementById("playlist-button").addEventListener("click", function () {
            if (lastPlaylist != null) {
                playlistPage.show(lastPlaylist);
            }
        });

        document.getElementById("track-button").addEventListener("click", function () {
            if (lastTrack != null) {
                playerPage.show(lastTrack);
            }
        });

        // load modal data when clicking on the modal
        document.getElementById("upload-track-modal-button").addEventListener("click", function () {
            loadYears();
            loadGenres();
            showModal(document.getElementById("upload-track"));
        });
    }

    function HomePage() {
        this.show = function () {
            clearModals();
            clearBottonNavbar();
            loadCreatePlaylistModal();
            loadUploadTrackModal();
            loadButtons();
            loadPlaylists();
            document.getElementById("upload-track-modal-button").className = "button";
            document.getElementById("track-selector-modal-button").className = "button";
        }

        /**
         * Loads the HomePage, that is all the Playlists.
         */
        function loadPlaylists() {
            cleanMain();
            let mainLabel: Element = document.getElementsByClassName("main-label").item(0);
            mainLabel.id = HOMEPAGE_ID;
            mainLabel.textContent = HOMEPAGE_LABEL;

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
         * Load buttons and button functionality outside the main div in the home view.
         */
        function loadButtons(): void {
            // Replace the track selector button and add "create playlist" functionality;
            // needed for removing already present event listeners, as this button is also used for adding tracks to a playlist.
            let modalButton = document.getElementById("track-selector-modal-button");
            let newButton = modalButton.cloneNode(true);
            modalButton.parentNode.replaceChild(newButton, modalButton);
            newButton.textContent = "Add Playlist"
            newButton.addEventListener("click", () => {
                loadUserTracks(document.getElementById("track-selector"));
                showModal(document.getElementById("create-playlist"));
            });

            // Even if no submit button is present, forms with a single implicit submission blocking field still submit when the Enter key is pressed
            // https://html.spec.whatwg.org/multipage/form-control-infrastructure.html#implicit-submission
            document.getElementById("create-playlist").getElementsByTagName("form").item(0).addEventListener("submit", (e) => {
                e.preventDefault();
            });

            // Create new playlist
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

                                    // Update the home view with newly created playlist
                                    let itemsContainer: HTMLElement = document.querySelector(".items-container");
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

            // Upload track
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
            });
        }

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
                playlistPage.show(playlist);
            });

            button.appendChild(span);
            return button;
        }


        /**
         * Loads the modal for creating playlists to the modal container.
         */
        function loadCreatePlaylistModal(): void {
            let modalContainer: HTMLElement = document.getElementById("modals"),
                modal: HTMLElement = createModal("create-playlist", "Create new playlist", "create-playlist-btn", "Create playlist"),
                form: HTMLFormElement = modal.getElementsByTagName("form").item(0), navbar: Node = form.firstChild;

            let titleInput: HTMLInputElement = document.createElement("input");
            titleInput.type = "text";
            titleInput.className = "text-field";
            titleInput.name = "playlistTitle";
            titleInput.placeholder = "Title";
            titleInput.required = true;
            form.insertBefore(titleInput, navbar);
            form.insertBefore(document.createElement("br"), navbar);
            form.insertBefore(document.createElement("br"), navbar);

            let label: HTMLLabelElement = document.createElement("label");
            label.className = "label";
            label.htmlFor = "track-selector";
            label.textContent = "Select songs to add:"
            form.insertBefore(label, navbar);
            form.insertBefore(document.createElement("br"), navbar);

            let selector: HTMLSelectElement = document.createElement("select");
            selector.className = "text-field";
            selector.id = "track-selector";
            selector.name = "selectedTracks";
            selector.multiple = true;
            form.insertBefore(selector, navbar);

            // This will hold errors and success messages
            form.insertBefore(document.createElement("div"), navbar);

            modalContainer.appendChild(modal);
        }

        /**
         * Loads the modal for uploading tracks to the modal container.
         */
        function loadUploadTrackModal(): void {
            let modalContainer: HTMLElement = document.getElementById("modals"),
                modal: HTMLElement = createModal("upload-track", "Upload Track", "upload-track-btn", "Add track"),
                form: HTMLFormElement = modal.getElementsByTagName("form").item(0), navbar: Node = form.firstChild;

            let titleInput: HTMLInputElement = document.createElement("input");
            titleInput.type = "text";
            titleInput.className = "text-field";
            titleInput.name = "title";
            titleInput.placeholder = "Title";
            titleInput.required = true;
            form.insertBefore(titleInput, navbar);
            form.insertBefore(document.createElement("br"), navbar);

            let artistInput: HTMLInputElement = document.createElement("input");
            artistInput.type = "text";
            artistInput.className = "text-field";
            artistInput.name = "artist";
            artistInput.placeholder = "Artist";
            artistInput.required = true;
            form.insertBefore(artistInput, navbar);
            form.insertBefore(document.createElement("br"), navbar);

            let albumInput: HTMLInputElement = document.createElement("input");
            albumInput.type = "text";
            albumInput.className = "text-field";
            albumInput.name = "album";
            albumInput.placeholder = "Album title";
            albumInput.required = true;
            form.insertBefore(albumInput, navbar);
            form.insertBefore(document.createElement("br"), navbar);


            let yearSelector: HTMLSelectElement = document.createElement("select");
            yearSelector.className = "text-field";
            yearSelector.name = "year";
            yearSelector.id = "year-selection";
            yearSelector.required = true;
            form.insertBefore(yearSelector, navbar);
            form.insertBefore(document.createElement("br"), navbar);

            let genreSelector: HTMLSelectElement = document.createElement("select");
            genreSelector.className = "text-field";
            genreSelector.name = "genre";
            genreSelector.id = "genre-selection";
            genreSelector.required = true;
            form.insertBefore(genreSelector, navbar);
            form.insertBefore(document.createElement("br"), navbar);

            let trackLabel: HTMLLabelElement = document.createElement("label");
            trackLabel.className = "label";
            trackLabel.htmlFor = "musicTrack";
            trackLabel.textContent = "Track:"
            form.insertBefore(trackLabel, navbar);

            let trackInput: HTMLInputElement = document.createElement("input");
            trackInput.type = "file";
            trackInput.name = "musicTrack";
            trackInput.id = "musicTrack";
            trackInput.required = true;
            form.insertBefore(trackInput, navbar);
            form.insertBefore(document.createElement("br"), navbar);

            let imageLabel: HTMLLabelElement = document.createElement("label");
            imageLabel.className = "label";
            imageLabel.htmlFor = "image";
            imageLabel.textContent = "Album image:"
            form.insertBefore(imageLabel, navbar);

            let imageInput: HTMLInputElement = document.createElement("input");
            imageInput.type = "file";
            imageInput.name = "image";
            imageInput.id = "image";
            imageInput.required = true;
            form.insertBefore(imageInput, navbar);

            form.insertBefore(document.createElement("div"), navbar);

            modalContainer.appendChild(modal);
        }

    }

    function PlaylistPage() {
        this.show = function (playlist: Playlist) {
            clearBottonNavbar();
            clearModals();
            loadAddTracksModal();
            loadPlaylistView(playlist);
            document.getElementById("upload-track-modal-button").className = "button hidden";
            document.getElementById("track-selector-modal-button").className = "button";
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
            cleanMain()
            container.setAttribute("class", "items-container");
            main.appendChild(container);

            for (let i: number = 0; i < 5; i++) {
                let track = tracks[i + trackGroup * 5];
                if (track == null)
                    break;
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
                    playerPage.show(track);
                });

                button.appendChild(text);
                text.appendChild(span_1);
                text.appendChild(document.createElement("br"));
                text.appendChild(span_2);
                button.appendChild(image);
                container.appendChild(button);
            }
        }

        /**
         * Load all the Tracks associated to a Playlist.
         */
        function loadPlaylistTracks(playlist: Playlist) {
            cleanMain()
            let mainLabel: Element = document.getElementsByClassName("main-label").item(0);
            mainLabel.id = PLAYLIST_PAGE_ID;
            mainLabel.textContent = playlist.title;

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

                            // pass the list of all Tracks and setup buttons
                            tracklist = tracks;
                            trackGroup = 0;
                            trackGrid(tracks);
                            loadPrevNextButton();
                        } else {
                            // request failed, handle it
                            // self.listcontainer.style.visibility = "hidden";
                            alert("Cannot recover data. Maybe the User has been logged out."); //for demo purposes
                        }
                    }
                });
        }

        /**
         * Load everything needed for viewing and interacting with the playlist and its contents
         * @param playlist
         */
        function loadPlaylistView(playlist: Playlist): void {
            loadPlaylistTracks(playlist)

            // Replace the track selector button and add "add tracks to playlist" functionality;
            // needed for removing already present event listeners, as this button is also used for creating a playlist.
            let modalButton = document.getElementById("track-selector-modal-button");
            let newButton = modalButton.cloneNode(true);

            modalButton.parentNode.replaceChild(newButton, modalButton);
            newButton.textContent = "Add Tracks"
            newButton.addEventListener("click", () => {
                loadUserTracks(document.getElementById("track-selector"), playlist);
                showModal(document.getElementById("add-tracks"));
            });


            document.getElementById("add-tracks-btn").addEventListener("click", function () {
                let self: HTMLElement = this;
                let form: HTMLFormElement = this.closest("form");

                if (form.checkValidity()) {
                    makeCall("POST", "AddTracks?playlistId=" + playlist.id, form, function (req: XMLHttpRequest) {
                        if (req.readyState == XMLHttpRequest.DONE) {
                            switch (req.status) {
                                case 201:
                                    loadPlaylistTracks(playlist);
                                    loadUserTracks(document.getElementById("track-selector"), playlist);
                                    self.parentElement.previousElementSibling.setAttribute("class", "success");
                                    self.parentElement.previousElementSibling.textContent = "Tracks added successfully";
                                    form.reset();
                                    break;
                            }
                        }
                    }, false);
                } else {
                    form.reportValidity();
                }
            });
            let bottomNavbar: HTMLDivElement = document.createElement("div");
            bottomNavbar.id = "bottom-nav-bar";
            bottomNavbar.className = "nav-bar";
            document.getElementById("main").after(bottomNavbar);
        }

        /**
         * Loads the modal for adding tracks to a playlist to the modal container.
         */
        function loadAddTracksModal(): void {
            let modalContainer: HTMLElement = document.getElementById("modals"),
                modal: HTMLElement = createModal("add-tracks", "Add tracks to playlist", "add-tracks-btn", "Add tracks"),
                form: HTMLFormElement = modal.getElementsByTagName("form").item(0), navbar: Node = form.firstChild;

            let label: HTMLLabelElement = document.createElement("label");
            label.className = "label";
            label.htmlFor = "track-selector";
            label.textContent = "Select songs to add:"
            form.insertBefore(label, navbar);
            form.insertBefore(document.createElement("br"), navbar);

            let selector: HTMLSelectElement = document.createElement("select");
            selector.className = "text-field";
            selector.id = "track-selector";
            selector.name = "selectedTracks";
            selector.multiple = true;
            form.insertBefore(selector, navbar);

            // This will hold errors and success messages
            form.insertBefore(document.createElement("div"), navbar);

            modalContainer.appendChild(modal);
        }

        /**
         * Load the buttons for changing the viewed track group in the playlist view.
         */
        function loadPrevNextButton(): void {
            let navbar = document.getElementById("bottom-nav-bar");
            navbar.innerHTML = "";

            if (trackGroup > 0) {
                let button: HTMLButtonElement = document.createElement("button");
                button.className = "button";
                button.type = "button";
                button.textContent = "Previous Tracks";
                button.addEventListener("click", () => {
                    trackGroup--;
                    trackGrid(tracklist);
                    loadPrevNextButton();
                });
                navbar.appendChild(button);
            }

            let spacer: HTMLElement = document.createElement("div");
            spacer.className = "spacer";
            navbar.appendChild(spacer);

            if (tracklist.length > 5 * (1 + trackGroup)) {
                let button: HTMLButtonElement = document.createElement("button");
                button.className = "button";
                button.type = "button";
                button.textContent = "Next Tracks";
                button.addEventListener("click", () => {
                    trackGroup++;
                    trackGrid(tracklist);
                    loadPrevNextButton();
                });
                navbar.appendChild(button);
            }
        }
    }

    function PlayerPage() {
        this.show = function (track: Track) {
            loadSingleTrack(track);
            clearModals();
            clearBottonNavbar();
            document.getElementById("upload-track-modal-button").className = "button hidden";
            document.getElementById("track-selector-modal-button").className = "button hidden";
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

        /**
         * Load a single Track from a Playlist.
         */
        function loadSingleTrack(track: Track) {
            // clean main div
            cleanMain();

            let mainLabel: Element = document.getElementsByClassName("main-label").item(0);
            mainLabel.id = PLAYER_PAGE_ID;
            mainLabel.textContent = track.title;

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
    }

    /**
     * Get user tracks and add them to the track selector parameter
     * @param trackSelector
     * @param playlist optional parameter used for just loading tracks not present in the specified playlist
     */
    function loadUserTracks(trackSelector: HTMLElement, playlist: Playlist = null) {
        trackSelector.innerHTML = "";
        let url: string;
        if (playlist == null) {
            url = "GetUserTracks";
        } else {
            url = "GetTracksNotInPlaylist?playlistTitle=" + playlist.title;
        }

        makeCall("GET", url, null, function (req: XMLHttpRequest) {
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
                    } else {
                        trackSelector.setAttribute("size", "10");
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
     * Loads the musical genres for upload track modal.
     */
    function loadGenres() {

        makeCall("GET", "genres.json", null, (req: XMLHttpRequest) => {
            let genres: string[];

            if (req.readyState == XMLHttpRequest.DONE) {
                if (req.status == 200) {
                    genres = JSON.parse(req.responseText);
                } else {
                    genres = [];
                }

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
                });
            }
        });
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
})();