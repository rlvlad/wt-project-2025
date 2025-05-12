#set align(horizon)

= Abstract

/ Overview: This project hosts the source code -- which can be found #link("https://github.com/VictuarVi/tiw-project-2025")[on Github] -- for a web server that handles a playlist management system. A user is able to register, login and then upload tracks. The tracks are strictly associated to one user, similar to how a cloud service works. The user will be able to create playlists, sourcing from their tracks, and listem to them.

It should be noted there are two versions: a *only-HTML version*, which is structured as a series of separate webpages; and a *JS version*, which is structured as a single-page webapp. The functionalities are mostly the same, the code changes at a frontend level. For more information see @original-submission.

Both of the them feature the same CSS code (see @css-styling).

/ Tools: To create the project, our professor decided to adopt the following technologies: #text(fill: rgb("#5283A2"), weight: "bold", "Java"), for the backend server with servlets leveraging Jakarta's API capabilities; #text(fill: rgb("#005F0F"), weight: "bold", "Thymeleaf"), a template engine; and #text(fill: rgb("#ae8e26"), weight: "bold", "Apache Tomcat"), to run the server.

#let sqlite(string: "SQLite") = {
 set text(fill: gradient.linear(rgb("#0F80CC"), rgb("#81CCF2")), weight: "bold")
  box(string)
}

_Many liberties were taken_ in regards to the DMBS:
- For the HTML version, we decided to use #text(fill: rgb("#192C5F"), weight: "bold")[MariaDB] instead of MySQL, since the former is a open source fork of MySQL, one of the most widely used DBMS
- For the JS version, we landed on #sqlite() to create a static Github pages website

// https://gist.github.com/felsenhower/a975c137732e20273f47a117e0da3fd1
#let LaTeX = {
  set text(font: "New Computer Modern")
  let A = (
    offset: (
      x: -0.33em,
      y: -0.3em,
    ),
    size: 0.7em,
  )
  let T = (
    x_offset: -0.12em
  )
  let E = (
    x_offset: -0.2em,
    y_offset: 0.23em,
    size: 1em
  )
  let X = (
    x_offset: -0.1em
  )
  [L#h(A.offset.x)#text(size: A.size, baseline: A.offset.y)[A]#h(T.x_offset)T#h(E.x_offset)#text(size: E.size, baseline: E.y_offset)[E]#h(X.x_offset)X]
}

Last but absolutely not least, this very document you are reading now has been typeset with none-other than #text(fill: eastern, weight: "bold")[Typst] @typst, the much needed successor to #LaTeX. Also, to create sequence diagrams we made use of the `chronos` package @chronos.

/ Configuration & Run: In order to run this project, the following packages and their respective versions are to be installed:
#columns(3)[
  - Java JDK 24 @java
  - Apache Maven @maven
  #colbreak()
  - Apache Tomcat 10 @tomcat
  - Thymeleaf @thymeleaf
  #colbreak()
  - MariaDB @mariadb
  - SQLite @sqlite
]

Then Maven will fetch all the corrected dependencies (such as the JDBC driver). We opted to use IntelliJ Idea Ultimate Edition @intellij though there are no restrictions -- feel free to use whatever editor you want, even Eclipse, #emph[if you must]#footnote[#emph[I wrote that #emph[only] out of kindess, since I wouldn't recommend it even to my worst enemy. --- `victuarvi`.]]. Once you made sure all the dependencies are correctly installed, let Tomcat deploy the server, which will be found at#footnote[`[version]` is either `pure_html` or `js` depending on what you run.]:

#align(
  center,
  link("http://localhost:8080/pure_html_war_exploded", "http://localhost:8080/[version]_war_exploded"),
)

The credentials are stored in plain text in the database (see @register-sequence), while the tracks and images are stored in `target/webapp` (see @uploadtrack-sequence).

The repository is bundled with some mock data, which can be found in the corresponding folders of each subproject. They are copyright free songs @ncs because we didn't want to get sued #emoji.face.cover.
