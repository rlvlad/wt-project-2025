#import "../lib.typ":*

#set align(horizon)

= Abstract

/ Overview: This project hosts the source code -- which can be found #link("https://github.com/VictuarVi/wt-project-2025")[on Github] -- for a web server that handles a playlist management system. A user is able to register, login and then upload tracks. The tracks are strictly associated to one user, similar to how a cloud service works. The user will be able to create playlists -- sourcing from their tracks -- and listen to them.

It should be noted there are two subprojects: a (pure) *HTML version*, which is structured as a series of separate webpages; and a *RIA version* (#ria())#footnote[For historic reasons, in the project is is referred as just `js`.], which is structured as a single-page webapp. The functionalities are quite the same, the code changes mostly at a frontend level. For more information about the requirements for each version see @project-breakdown.

/ Tools: To create the project, our professor decided to adopt the following technologies: #text(fill: rgb("#5283A2"), weight: "bold", "Java"), for the backend server with servlets leveraging Jakarta's API capabilities; #text(fill: rgb("#ae8e26"), weight: "bold", "Apache Tomcat"), to run the server; for the HTML version, #text(fill: rgb("#005F0F"), weight: "bold", "Thymeleaf"), a template engine; whereas for the RIA one #text(fill: rgb("#dcca3f"), weight: "bold")[Javascript].

_Many liberties were taken_ in regards to the DMBS and RIA project:
- We decided to use #text(fill: rgb("#192C5F"), weight: "bold")[MariaDB] instead of MySQL, since the former is a open source fork of MySQL, one of the most widely used DBMS
- Instead of Javascript, we chose #text(fill: rgb("#3178C6"), weight: "bold")[Typescript]

Last but absolutely not least, this very document you are reading now has been typeset with none-other than #text(fill: eastern, weight: "bold")[Typst] @typst, the much needed successor to #LaTeX. Also, to create sequence diagrams we made use of the `chronos` package @chronos.

/ Configuration & Running: In order to run this project, the following packages and their respective versions are to be installed:
#columns[
  - Java JDK 24 @java
  - Apache Maven @maven
  #colbreak()
  - Apache Tomcat 10 @tomcat
  - MariaDB @mariadb
  // #colbreak()
  // - Thymeleaf @thymeleaf
  // - SQLite @sqlite
]

Then Maven will fetch all the corrected dependencies (such as the Thymeleaf, JDBC driver). We opted to use IntelliJ Idea Ultimate Edition @intellij though there are no restrictions on the IDE -- feel free to use whatever editor you want, even Eclipse, #emph[if you must]#footnote[#emph[I wrote that #emph[only] out of kindess, since I wouldn't recommend it even to my worst enemy. --- `victuarvi`.]]. Once you made sure all the dependencies are correctly installed, run the desired Tomcat configuration and let it deploy the server, which will be found at:

#align(
  center,
  link("http://localhost:8080/pure_html_war_exploded", "http://localhost:8080/[version]_war_exploded") + [: `[version]` is either `pure_html` or `js`],
)

The credentials are stored in plain text in the database (see @register-sequence), while the tracks and images are stored in `target/webapp` (see @uploadtrack-sequence).

The repository is bundled with some mock data, which can be found at the root of the project in the `mockdata` folder. They are copyright free songs @ncs because we didn't want to get sued #emoji.face.cover.
