// Helper methods
/**
 * Send requests to server.
 * @param method
 * @param url
 * @param formElement
 * @param callback
 * @param reset
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
 * @param id
 * @param titleText
 * @param buttonId
 * @param buttonText
 */
function createModal(id: string, titleText: string, buttonId: string, buttonText: string): HTMLElement {
    let modal: HTMLElement = document.createElement("div");
    modal.id = id;
    modal.className = "modal-window";

    let container: HTMLElement = document.createElement("div"), topNavbar: HTMLElement = document.createElement("div");
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
 * @param modal
 */
function showModal(modal: HTMLElement): void {
    modal.style.visibility = "visible"
    modal.style.pointerEvents = "auto"
}

/**
 * Delete the bottom navbar if present.
 */
function clearBottonNavbar(): void {
    let navbar: HTMLElement = document.getElementById("bottom-nav-bar");
    if (navbar != null)
        navbar.remove();
}

// Entities
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
}