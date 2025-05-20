(function () {
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
            }, false);
        });

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

        // load modal data when clicking on the modal
        document.getElementById("upload-track-button").addEventListener("click", function () {
            loadYears();
            loadGenres();
        })

        document.getElementById("add-playlist-button").addEventListener("click", () => {
            loadUserTracks(document.getElementById("track-selector"))
        });

        // update homepage with new playlist
        document.getElementById("create-playlist-btn").addEventListener("click", function () {
            let self: HTMLElement = this;
            makeCall("POST", "CreatePlaylist", this.closest("form"), function (req: XMLHttpRequest) {
                if (req.readyState == XMLHttpRequest.DONE) {
                    let message: string = req.responseText;
                    if (req.status == 201) {
                        let newPlaylist: Playlist = JSON.parse(message);
                        let itemsContainer: HTMLElement = document.querySelector(".items-container");
                        itemsContainer.insertBefore(createPlaylistContainer(newPlaylist), itemsContainer.firstChild);
                        location.hash = "";
                    } else {
                        self.parentElement.previousElementSibling.textContent = message;
                    }
                }
            });
        });
    }

    // Helpers methods

    /**
     * Delete everything from main div and appends to it the track container, used to hold both the Playlists
     * and the Tracks.
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
            container.appendChild(createPlaylistContainer(playlist));
        })
    }

    /**
     * Load the Tracks of a Playlist.
     *
     * @param tracks array of Tracks
     * @param reorder whether to let this track be draggable or not
     */
    function trackGrid(tracks: Track[], reorder: boolean) {
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
            // if (reorder === true) {
            //     button.setAttribute("class", "draggable");
            // }

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
            image.setAttribute("alt", "Track player");
            image.setAttribute("width", "100");
            image.setAttribute("height", "100");

            button.addEventListener("click", () => {
                loadSingleTrack(track.id.toString())
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
        image.setAttribute("alt", "Track player");
        image.setAttribute("width", "200");
        image.setAttribute("height", "100");

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
    function loadPlaylistTracks(playlistId: string, reorder = false) {
        cleanMain()

        makeCall("GET", "Playlist?playlistId=" + playlistId,
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
                        trackGrid(tracks, reorder);
                    } else {
                        // request failed, handle it
                        // self.listcontainer.style.visibility = "hidden";
                        alert("Cannot recover data. Maybe the User has been logged out."); //for demo purposes
                    }
                }
            });

        /**
         * If reorder is true, then add the various drag events listeners.
         */
        // if (reorder === true) {
        //     const draggable_elements = Array(document.getElementsByClassName("draggable"));
        //
        //     draggable_elements
        //         .map(e => e as unknown as HTMLButtonElement)
        //         .forEach(button => {
        //             button.draggable = true;
        //             button.addEventListener("dragstart", dragStart);
        //             button.addEventListener("dragover", dragOver);
        //             button.addEventListener("dragleave", dragLeave);
        //             button.addEventListener("drop", drop);
        //         })
        // }
    }

    /**
     * Load a single Track from a Playlist.
     */
    function loadSingleTrack(trackId: string) {
        // clean main div
        let main_div: HTMLElement = document.getElementById("main");
        main_div.innerHTML = "";

        makeCall("GET", "Track?track_id=" + trackId, null,
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

    /**
     * Get user tracks and add them to the track selector parameter.
     *
     * @param trackSelector
     */
    function loadUserTracks(trackSelector: HTMLElement) {
        trackSelector.innerHTML = "";

        makeCall("GET", "GetUserTracks", null, function (req: XMLHttpRequest) {
            if (req.readyState == XMLHttpRequest.DONE) {
                let message: string = req.responseText;
                if (req.status == 200) {
                    let tracks: Track[] = JSON.parse(message);
                    if (tracks.length === 0) {
                        let parent: HTMLElement = trackSelector.parentElement;
                        let span: HTMLSpanElement = document.createElement("span");

                        span.textContent = "There are no available tracks to be added."
                        parent.insertBefore(span, trackSelector);

                        parent.removeChild(trackSelector);
                        parent.removeChild(parent.getElementsByClassName("label").item(0));

                        return;
                    }
                    tracks.forEach(function (track: Track) {
                        let option: HTMLOptionElement = document.createElement("option");
                        option.value = track.id.toString();
                        option.textContent = track.artist + " - " + track.title + " ( " + track.year + " )"
                        trackSelector.appendChild(option);
                    });
                } else {
                    alert("Cannot recover data. Maybe the User has been logged out."); //for demo purposes
                }
            }
        });
    }

    // TODO unify the previous and following method

    /**
     * Get user Tracks and creates list items.
     *
     * @param trackSelector
     */
    function loadUserTracksOl(trackSelector: HTMLOListElement) {
        trackSelector.innerHTML = "";

        makeCall("GET", "GetUserTracks", null, function (req: XMLHttpRequest) {
            if (req.readyState == XMLHttpRequest.DONE) {
                let message: string = req.responseText;
                if (req.status == 200) {
                    let tracks: Track[] = JSON.parse(message);
                    if (tracks.length === 0) {
                        let parent: HTMLElement = trackSelector.parentElement;
                        let span: HTMLSpanElement = document.createElement("span");

                        span.textContent = "There are no available tracks to be added."
                        parent.insertBefore(span, trackSelector);

                        parent.removeChild(trackSelector);
                        parent.removeChild(parent.getElementsByClassName("label").item(0));

                        return;
                    }
                    tracks.forEach(function (track: Track) {
                        let list_item: HTMLLIElement = document.createElement("li");
                        list_item.draggable = true;
                        list_item.addEventListener("dragstart", dragStart);
                        list_item.addEventListener("dragover", dragOver);
                        list_item.addEventListener("dragleave", dragLeave);
                        list_item.addEventListener("drop", drop);
                        list_item.value = track.id;
                        list_item.textContent = track.artist + " - " + track.title + " ( " + track.year + " )"
                        trackSelector.appendChild(list_item);
                    });
                } else {
                    alert("Cannot recover data. Maybe the User has been logged out."); //for demo purposes
                }
            }
        });
    }

    /**
     * Creates and returns a button based on the playlist parameter.
     *
     * @param playlist
     */
    function createPlaylistContainer(playlist: Playlist): HTMLDivElement {
        let div: HTMLDivElement = document.createElement("div");
        div.setAttribute("class", "single-item");

        let playlist_button: HTMLButtonElement = document.createElement("button");
        playlist_button.setAttribute("name", "playlistId");
        playlist_button.setAttribute("class", "playlist-button");

        let span: HTMLSpanElement = document.createElement("span");
        // span.setAttribute("class", "playlist-title");
        span.textContent = playlist.title;

        div.addEventListener("click", () => {
            loadPlaylistTracks(playlist.id.toString());
        }, false);

        playlist_button.appendChild(span);

        let playlist_reorder = document.createElement("button");
        playlist_reorder.setAttribute("name", "playlistId");

        let playlist_reorder_icon: HTMLImageElement = document.createElement("img");
        playlist_reorder_icon.setAttribute("class", "reorder-button");
        playlist_reorder_icon.setAttribute("src", "img/reorder/reorder.svg");
        playlist_reorder_icon.setAttribute("width", "40");
        playlist_reorder_icon.setAttribute("height", "40");

        playlist_reorder.appendChild(playlist_reorder_icon);

        playlist_reorder.addEventListener("click", (e) => {
            e.stopPropagation();
            loadReorderModal(playlist);
        })

        div.appendChild(playlist_button);
        div.appendChild(playlist_reorder);

        return div;
    }

    // Drag events

    let startElement: HTMLLIElement

    /**
     * As soon as the User drags an Element.
     *
     * @param event the drag event
     */
    function dragStart(event: Event) {
        let list_item: HTMLLIElement = (event as unknown as HTMLElement).closest("li");
        list_item.style.cursor = "pointer"; // or convert to a proper class
        startElement = event.target as HTMLLIElement;
    }


    /**
     * The User is dragging the Element around.
     *
     * @param event during the drag event
     */
    function dragOver(event: Event) {
        event.preventDefault()
        let list_item: HTMLLIElement = (event as unknown as HTMLElement).closest("li");
        list_item.style.cursor = "grab";
    }


    /**
     * The User has started dragging the Element.
     *
     * @param event after the drag event
     */
    function dragLeave(event: Event) {
        let list_item: HTMLLIElement = (event as unknown as HTMLElement).closest("li");
        list_item.style.cursor = "pointer";
    }

    /**
     * The User has dropped the Track in the desired location.
     *
     * @param event the drop event
     */
    function drop(event: Event) {
        // HTML output
        let finalDest: HTMLLIElement = (event as unknown as HTMLLIElement).closest("li");

        let completeList: HTMLUListElement = finalDest.closest("ol");
        let songsArray: HTMLLIElement[] = Array(completeList.querySelectorAll("li"))
            // I really love TypeScript, this is VERY MUCH NECESSARY
            .map(e => e as unknown as HTMLLIElement);

        let indexDest: number = songsArray.indexOf(finalDest);

        if (songsArray.indexOf(startElement) < indexDest) {
            startElement.parentElement.insertBefore(
                startElement,
                songsArray[indexDest + 1],
            );
        } else {
            startElement.parentElement.insertBefore(
                startElement,
                songsArray[indexDest],
            );
        }
        startElement.value = indexDest;

        // update the new position by making a POST call to the database
    }

    /**
     * Generates the modal to reorder the Tracks.
     *
     * @param playlist Playlist from which recover the tracks
     */
    function loadReorderModal(playlist: Playlist) {
        /**
         * Make the reorder track modal visible.
         */
        function openReorderTracksModal() {
            let modal_div: HTMLElement = document.getElementById("reorder-tracks-modal");
            modal_div.style.visibility = "visible";
            modal_div.style.opacity = "1";
            modal_div.style.pointerEvents = "auto";
        }

        // if the modal has already been generated, make it visible
        if (document.querySelector("#reorder-tracks-modal")) {
            openReorderTracksModal();
            return;
        }

        let body: HTMLElement = document.body;
        let modal_div: HTMLDivElement = document.createElement("div");
        modal_div.setAttribute("id", "reorder-tracks-modal");
        modal_div.setAttribute("class", "modal-window");

        let inner_div: HTMLDivElement = document.createElement("div");

        // Top nav bar
        let top_nav_bar: HTMLDivElement = document.createElement("div");
        top_nav_bar.setAttribute("class", "nav-bar");

        let title_div: HTMLDivElement = document.createElement("div");
        title_div.setAttribute("class", "modal-title");
        title_div.textContent = "Reorder Tracks in " + playlist.title.toString();

        let spacer: HTMLDivElement = document.createElement("div");
        spacer.setAttribute("class", "spacer");

        let modal_close: HTMLAnchorElement = document.createElement("a");
        modal_close.setAttribute("href", "#");
        modal_close.setAttribute("title", "Close");
        modal_close.setAttribute("class", "modal-close");
        modal_close.textContent = "Close";

        modal_close.addEventListener("click", () => {
            closeReorderModal();
        })

        top_nav_bar.appendChild(title_div);
        top_nav_bar.appendChild(spacer);
        top_nav_bar.appendChild(modal_close);

        // Main form
        let main_form: HTMLFormElement = document.createElement("form");
        main_form.setAttribute("method", "POST");
        main_form.setAttribute("action", "#");

        let label: HTMLLabelElement = document.createElement("label");
        label.setAttribute("class", "label");
        label.setAttribute("for", "track-reorder");
        label.textContent = "Drag the track to reorder:";

        let ordered_list: HTMLOListElement = document.createElement("ol");
        ordered_list.setAttribute("name", "reorderingTracks");
        ordered_list.setAttribute("id", "track-reorder");
        ordered_list.setAttribute("class", "text-field");

        loadUserTracksOl(ordered_list);

        let bottom_div: HTMLDivElement = document.createElement("div");
        bottom_div.setAttribute("class", "nav-bar");

        let reorder_track_btn: HTMLButtonElement = document.createElement("button");
        reorder_track_btn.setAttribute("id", "track-reorder-btn");
        reorder_track_btn.setAttribute("class", "button");
        reorder_track_btn.setAttribute("value", "Reorder Tracks");
        reorder_track_btn.textContent = "Reorder Tracks";

        reorder_track_btn.addEventListener("click", (e: MouseEvent) => {
            saveOrder(e, playlist.id.toString());
        });

        bottom_div.appendChild(reorder_track_btn);

        main_form.appendChild(label);
        main_form.appendChild(document.createElement("br"));
        main_form.appendChild(document.createElement("br"));
        main_form.appendChild(ordered_list);
        main_form.appendChild(bottom_div);

        // Combine all into modal div
        inner_div.appendChild(top_nav_bar);
        inner_div.appendChild(main_form);
        modal_div.appendChild(inner_div);

        body.appendChild(modal_div);

        // Make it visible
        openReorderTracksModal();
    }

    /**
     * Closes the reorder tracks modal.
     */
    function closeReorderModal() {
        let modal_div: HTMLElement = document.getElementById("reorder-tracks-modal");

        // Make it not visible
        modal_div.style.visibility = "hidden";
        modal_div.style.opacity = "0";
        modal_div.style.pointerEvents = "none";
    }

    /**
     * Save new Tracks custom order.
     */
    function saveOrder(e: MouseEvent, playlistId: string) {
        let songsContainer: HTMLUListElement = (e as unknown as HTMLElement).closest("ul");
        let trackIds: number[] = Array(songsContainer.querySelectorAll("li"))
            .map(e => e as unknown as HTMLLIElement)
            .map(e => e.value);

        for (let i = 0; i < trackIds.length; i++) {
            let params: string[] = []

            params.push("playlistId=" + playlistId);
            params.push("trackId=" + trackIds[i]);
            params.push("newOrder=" + i);

            makeCall("POST", "TrackReordering?" + params.join("&"), null, null);
        }
    }
})();