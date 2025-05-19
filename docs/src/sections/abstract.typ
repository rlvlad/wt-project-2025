#import "../lib.typ":*

#set align(horizon)

= Abstract

/ Overview: This project hosts the source code -- which can be found #link("https://github.com/VictuarVi/tiw-project-2025")[on Github] -- for a web server that handles a playlist management system. A user is able to register, login and then upload tracks. The tracks are strictly associated to one user, similar to how a cloud service works. The user will be able to create playlists, sourcing from their tracks, and listem to them.

It should be noted there are two versions: a *HTML version*, which is structured as a series of separate webpages; and a *RIA version*, which is structured as a single-page webapp. The functionalities are quite the same, the code changes mostly at a frontend level. For more information about the requirements for each version see @project-breakdown.

Both of the them feature the same CSS code (see @css-styling).

/ Tools: To create the project, our professor decided to adopt the following technologies: #text(fill: rgb("#5283A2"), weight: "bold", "Java"), for the backend server with servlets leveraging Jakarta's API capabilities; #text(fill: rgb("#ae8e26"), weight: "bold", "Apache Tomcat"), to run the server; for the HTML version, #text(fill: rgb("#005F0F"), weight: "bold", "Thymeleaf"), a template engine; whereas for the RIA one #text(fill: rgb("#3178C6"), weight: "bold")[Typescript].

_Some liberties were taken_ in regards to the DMBS: we decided to use #text(fill: rgb("#192C5F"), weight: "bold")[MariaDB] instead of MySQL, since the former is a open source fork of MySQL, one of the most widely used DBMS.

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
  // - SQLite @sqlite
]

Then Maven will fetch all the corrected dependencies (such as the JDBC driver). We opted to use IntelliJ Idea Ultimate Edition @intellij though there are no restrictions -- feel free to use whatever editor you want, even Eclipse, #emph[if you must]#footnote[#emph[I wrote that #emph[only] out of kindess, since I wouldn't recommend it even to my worst enemy. --- `victuarvi`.]]. Once you made sure all the dependencies are correctly installed, let Tomcat deploy the server, which will be found at#footnote[`[version]` is either `pure_html` or `js` depending on what you run.]:

#align(
  center,
  link("http://localhost:8080/pure_html_war_exploded", "http://localhost:8080/[version]_war_exploded"),
)

The credentials are stored in plain text in the database (see @register-sequence), while the tracks and images are stored in `target/webapp` (see @uploadtrack-sequence).

The repository is bundled with some mock data, which can be found in the corresponding folders of each subproject. They are copyright free songs @ncs because we didn't want to get sued #emoji.face.cover.
