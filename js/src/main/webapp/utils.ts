function makeCall(method: string, url: string, formElement: HTMLFormElement, callback: { (req: any): void; (req: any): void; (req: { readyState: number; responseText: string; status: number; }): void; (arg0: XMLHttpRequest): void; }, reset = true) {
    let req:XMLHttpRequest = new XMLHttpRequest();
    req.onreadystatechange = function () {
        callback(req);
    };
    req.open(method, url);
    if (formElement == null) {
        req.send();
    } else {
        let formData:FormData = new FormData(formElement)
        req.send(formData);
    }
    if (formElement != null && reset === true) {
        formElement.reset();
    }
}

// Logout sequence
// (function (){
//     document.getElementById("logout-button").addEventListener("click", logout);
// }());
//
// function logout() {
//     makeCall("GET", "Logout", null, null, false);
// }

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
