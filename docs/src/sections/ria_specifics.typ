#import "../lib.typ"

= RIA-specific features<ria-specifics>

This project started from the HTML and thymeleaf, where we developed most of the servlets, the ideas and the HTML webpages. Then, we moved on the next task: the RIA, that is the Rich Internet Application.

For this very reason, most of the features were ported to the latter subproject: there is no need to go through the components and logic all over again. Still, the RIA subproject -- the "JavaScript version" -- requires more features and some changes to how the overwall server works.

Furthermore, by using JavaScript, some features can be upgraded -- this mainly applies to the modal @css-modal. Briefly, the main changes are as follows:

- Thymeleaf has been completely removed, since everything it did can be done via Javascript

- All the project now runs in a single webapp after the user has logged in#footnote[This effectively means that before the homepage, the playlist and the player were _all_ separate webpages; now, they are all-in-one -- hence why _Rich_ Internet Application.]

- To account for the new User Experience, we developed the sidebar to host the various buttons; see @ria-css-sidebar

/ Typescript: Instead of Javascript we opted for #text(fill: rgb("#3178C6"), weight: "bold")[Typescript]. This was done mainly for two reasons:  the retrocompability with Javascript (since Typescript transpiles in JS) and the static typing system, which can be quite bothersome in some cases, but saves a lot of time overall.

// modifiche alle classi

// drag n drop
