#set align(horizon)

= Abstract

/ Overview: This project hosts the source code -- which can be found #link("https://github.com/VictuarVi/tiw-project-2025")[on Github] -- for a web server that handles a playlist management system. A user is able to register, login and then upload tracks. The tracks are strictly associated to one user, similar to how a cloud service works. The user will be able to create playlists, sourcing from their tracks, and listem to them.

It should be noted there are two versions: a *only-HTML version*, which is structured as a series of seperate webpages; and a *JS version*, which is structured a single-page webapp. The functionalities are mostly the same, the code changes at a frontend level. For more information see @original-submission.

Both of the them feature the same CSS code (see @css-styling).

/ Technologies used: In order to create the project, our professor decided to adopt the following technologies: #text(fill: rgb("#5283A2"), weight: "bold", "Java"), for the backend server with servlets leveraging Jakarta's API capabilities; #text(fill: rgb("#005F0F"), weight: "bold", "Thymeleaf"), a template engine; and #text(fill: rgb("#ae8e26"), weight: "bold", "Apache Tomcat"), to run the server.

_Some liberties were taken_ and we decided to use #text(fill: rgb("#192C5F"), weight: "bold")[MariaDB] for the database#footnote[We also could have used SQLite and go for a static webpage.] instead of MySQL, since the former is a open source fork of MySQL, one of the most widely used DBMS.

/ Running: In order to run this project, the following programs are to be installed:
- Java JDK @java
- Apache Maven @maven
- Apache Tomcat @tomcat
- Thymeleaf @thymeleaf
- MariaDB @mariadb

The IDE we opted to use is #link("https://www.jetbrains.com/idea/")[IntelliJ Idea Ultimate Edition], though there are no restrictions -- feel free to use Eclipse#footnote[#emph[I wrote that out of kindess, since I wouldn't recommed it even to my worst enemy. --- `victuarvi`.]]. Once you made sure are all the dependencies are correctly installed, let Tomcat run the server, which will be found at:

#align(center, link("http://localhost:8080/pure_html_war_exploded", `http://localhost:8080/pure_html_war_exploded`))

The credentials are stored in plain text in the database (see @register-sequence), while the tracks and images are stored in `target/webapp` (see @uploadtrack-sequence).

The repository is bundled with some mock data, which can be found in the corresponding folder at the root of the project. They are copyright free songs because we didn't want to get sued #emoji.face.cover.
