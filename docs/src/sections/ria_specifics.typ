= RIA-specific features<ria-specifics>

// - Scomparsa completa di thymeleaf
// - Single webapp
// - Sidebar ==> cambi al CSS
// - Drag n Drop
// - Cambi al modal (200 OK etc)

Since the RIA project has been built upon the HTML+thymeleaf one, we opted to describe only #emph[what has been changed or tweaked] starting from there instead of going through all the single components another time.

In brief, the main changes are as follows:
- Thymeleaf has been completely removed, since everything it did can be done via Javascript
- All the project now runs in a single webapp after the user has logged in#footnote[This effectively means that before the homepage, the playlist and the player were _all_ separate webpages; now, they are all-in-one -- hence why _Rich_ Internet Application.]
- To account for the new User Experience, we developed the sidebar to host the various buttons (which works similarly to a bottom navigation bar on a smartphone application)
- To support the drag and drop feature, some modification were made to Java classes

Also, instead of Javascript we opted for #text(fill: rgb("#3178C6"), weight: "bold")[Typescript]. This was done mainly for two reasons:  the retrocompability with Javascript (since Typescript transpiles in JS) and the static typing system, which can be quite bothersome in some cases, but saves a lot of time overall.

== Sidebar

== Modals

== Updates to Java classes
