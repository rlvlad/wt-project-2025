#import "../lib.typ" :*

= Specifications completion

// - Tutto il css
// - La sidebar
// - Logout
// - Register

/ Introduction : There were many features planned, but due to time constraints they weren't implemented. They are all listed in @cut-content.

== In all subprojects

In addition to the requirements, we implemented a series of new features:

- Since the application does need to implement a login function, we thought to complement this with a logout button (@logout-sequence)
  - The motivation is the same with the registration button (@register-sequence)

- All the CSS styling (@css-styling), from colours to buttons to modals

- The top navigation bar, where the title of the page and various buttons are located (upload or add track, create playlist and logout)

== HTML-specific features<html-specifics>

The following features are HTML specific, which means they do not appear in the RIA subproject:

- The bottom navigation bar, where the Home button is located

== RIA-specific features<ria-specifics>

This project started from the HTML, where we developed most of the servlets, the ideas and the HTML webpages. Then, we moved on the next task: the RIA, that is the _Rich Internet Application_.

For this very reason, most of the features were ported to the latter subproject: there is no need to go through the components and logic all over again. Still, the RIA subproject -- the "JavaScript version" -- requires more features and some changes to how the overall server works. The #ria() symbol means that the currently described features is present _only_ in the RIA subproject, NOT in the HTML one.

Furthermore, by using JavaScript, some features can be upgraded -- this mainly applies to the modal @css-modal. Briefly, the main changes are as follows:

- Thymeleaf has been completely removed, since everything it did can be done via Javascript

- All the project now runs in a single webapp after the user has logged in#footnote[This effectively means that before the homepage, the playlist and the player were _all_ separate webpages; now, they are all-in-one -- hence why _Rich_ Internet Application.]

- To account for the new User Experience, we developed the sidebar to host the various buttons (@ria-css-sidebar)

/ Typescript: Instead of Javascript we opted for #text(fill: rgb("#3178C6"), weight: "bold")[Typescript]. This was done mainly for two reasons:  the retrocompability with Javascript (since Typescript transpiles in JS) and the static typing system, which can be quite bothersome in some cases, but saves a lot of time overall.
