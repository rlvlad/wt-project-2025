(function () {
    document.getElementById("login-button").addEventListener("click", (e) => {
        let form:HTMLFormElement = (e.target as HTMLElement).closest("form");
        if (form.checkValidity()) {
            makeCall("POST", "Login", form, (req:XMLHttpRequest) => {
                if (req.readyState === XMLHttpRequest.DONE) {
                    let message:string = req.responseText;
                    switch (req.status) {
                        case 200:
                            window.location.href = "home_page.html";
                            break;
                        case 400:
                        case 401:
                        case 500:
                            document.getElementById("error").textContent = message;
                            break;
                    }
                }
            });
        } else {
            form.reportValidity();
        }
    });

    document.getElementById("register-button").addEventListener("click", () => {
        window.location.href = "register.html"
    })
}());