(function () {
    document.getElementById("create-account-button").addEventListener("click", (e: MouseEvent) => register(e));

    /**
     * Register a new User. If successful, redirect to index; otherwise show error.
     *
     * @param e  mouse event from the User mouse event from the User
     */
    function register(e: MouseEvent) {
        let form = (e.target as HTMLElement).closest("form");
        if (form.checkValidity()) {
            makeCall("POST", "Register", form, (req: XMLHttpRequest) => {
                if (req.readyState === XMLHttpRequest.DONE) {
                    let message: string = req.responseText;
                    switch (req.status) {
                        case 201:
                            window.location.href = "index.html";
                            break;
                        case 400:
                        case 409:
                        case 500:
                            document.getElementById("error").firstChild.textContent = message;
                            document.getElementById("error").appendChild(document.createElement("hr"));
                            break;
                    }
                }
            });
        } else {
            form.reportValidity();
        }
    }
}());
