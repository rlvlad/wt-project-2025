function makeCall(method: string, url: string, formElement: HTMLFormElement, callback, reset = true) {
    let req = new XMLHttpRequest();
    req.onreadystatechange = function () {
        callback(req);
    };
    req.open(method, url);
    if (formElement == null) {
        req.send();
    } else {
        let formData = new FormData(formElement)
        req.send(formData);
    }
    if (formElement != null && reset === true) {
        formElement.reset();
    }
}