(function () {
    window.onload = function () {
        loadYears();
        loadGenres();
    }

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
        })

    /**
     * Creates the Playlists and then appends them in the corresponding div by creating a form
     * with inside a button, span.
     *
     * @param playlists array of Playlists
     */
    function playlistGrid(playlists: Playlist[]) {
        let cell: HTMLFormElement, button: HTMLButtonElement, span: HTMLSpanElement;
        let container: HTMLElement = document.getElementById("track-container");
        container.innerHTML = "";

        playlists.forEach(function (playlist: Playlist) {
            cell = document.createElement("form");
            cell.setAttribute("action", "playlist_page");
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
})();