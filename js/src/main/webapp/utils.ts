// Helper methods

/**
 * Make an asynchronous call to the server by specifying method, URL, form to send,
 * the function to execute and whether to reset the given form.
 *
 * @param method method of the request (usually GET, POST)
 * @param url URL to call
 * @param formElement form
 * @param callback function to execute upon received data
 * @param reset whether to reset the given form
 */
function makeCall(method: string, url: string, formElement: HTMLFormElement, callback: (arg0: XMLHttpRequest) => void, reset = true) {
    let req: XMLHttpRequest = new XMLHttpRequest();
    req.onreadystatechange = function () {
        callback(req);
    };
    req.open(method, url);
    if (formElement == null) {
        req.send();
    } else {
        let formData: FormData = new FormData(formElement)
        req.send(formData);
    }
    if (formElement != null && reset === true) {
        formElement.reset();
    }
}

/**
 * Delete everything from main div.
 */
function cleanMain() {
    let main_div: HTMLElement = document.getElementById("main");
    main_div.innerHTML = "";
}

/**
 * Delete everything from modals div.
 */
function clearModals(): void {
    document.getElementById("modals").innerHTML = "";
}

/**
 * Create basic modal element; used as a building block for creating modals.
 *
 * @param id id of this modal
 * @param titleText title of this modal
 * @param buttonId ID of the button
 * @param buttonText text of the button
 */
function createModal(id: string, titleText: string, buttonId: string, buttonText: string): HTMLElement {
    let modal: HTMLElement = document.createElement("div");
    modal.id = id;
    modal.className = "modal-window";

    let container: HTMLElement = document.createElement("div"),
        topNavbar: HTMLElement = document.createElement("div");
    topNavbar.className = "nav-bar";

    let title: HTMLElement = document.createElement("div");
    title.className = "modal-title";
    title.textContent = titleText;

    let spacer: HTMLElement = document.createElement("div");
    spacer.className = "spacer";

    let close: HTMLElement = document.createElement("div");
    close.className = "modal-close";
    close.textContent = "Close";
    close.addEventListener("click", () => {
        modal.style.visibility = "hidden"
        modal.style.pointerEvents = "none"
    });

    let form: HTMLFormElement = document.createElement("form");
    topNavbar.appendChild(title);
    topNavbar.appendChild(spacer);
    topNavbar.appendChild(close);
    container.appendChild(topNavbar);
    container.appendChild(form);
    modal.appendChild(container);

    let bottomNavbar: HTMLDivElement = document.createElement("div"),
        button: HTMLButtonElement = document.createElement("button");

    bottomNavbar.className = "nav-bar";
    button.id = buttonId;
    button.type = "button";
    button.className = "button";
    button.textContent = buttonText;
    bottomNavbar.appendChild(button);
    form.appendChild(bottomNavbar);

    return modal;
}

/**
 * Make the modal visible.
 *
 * @param modal modal to make visible
 */
function showModal(modal: HTMLElement): void {
    modal.style.visibility = "visible"
    modal.style.pointerEvents = "auto"
}

/**
 * Delete the bottom navbar if present.
 */
function clearBottomNavbar(): void {
    let navbar: HTMLElement = document.getElementById("bottom-nav-bar");
    if (navbar != null)
        navbar.remove();
}

/**
 * Get user tracks and add them to the track selector parameter.
 *
 * @param trackSelector HTML element to append the loaded user tracks
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
                alert("Cannot recover data. Maybe the User has been logged out.");
            }
        }
    });
}

// Entities
// These mirror the entities found in the entities Java package

interface User {
    id: number;
    nickname: string;
    password: string;
    name: string;
    surname: string;
}

interface Playlist {
    id: number;
    title: string;
    date: string;
    user: User;
}

interface Track {
    id: number
    title: string;
    artist: string;
    year: number;
    album_title: string;
    genre: string;
    image_path: string;
    song_path: string;
    song_checksum: string;
    image_checksum: string;
    custom_order: number;
}
