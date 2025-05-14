(function () {
    makeCall("GET", "HomePage", null,
        // callback function
        function (req: XMLHttpRequest) {
            if (req.readyState == XMLHttpRequest.DONE) { // == 4
                let message: string = req.responseText;
                if (req.status == 200) {
                    // parse JSON for user playlists
                    let playlists: [Playlist] = JSON.parse(message);

                    // @ts-ignore
                    if (playlists.length === 0) {
                        alert("The User has no playlists.");
                        return;
                    }

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
})();