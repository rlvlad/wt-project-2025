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
    custom_order: number;
}
