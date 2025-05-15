#import "../lib.typ":*

= Cut content

During the development, we had many ideas and thought about ways to implement them -- however, due to time and work restrictions, some features didn't make it to the final release. They can be categorized in features and optimizations.

== Features

In regards to the features, we wanted to implement *Next/Previous* buttons for the Playlists too, to make the application behave in a more coherent way: according to the submission, only the tracks in the playlist must implement it. Following this cohesion, the same can be said about the *Delete* functionalities: initially, along with the creation of a track/playlist we wanted to add a delete option -- if you add something, you might want to remove it at a later date.

/ JS: For the JavaScript project -- which is not correct to call like that, since we used TypeScript -- there were plans to implement a localization function, similar to how the HTML project works. It would have been a parser for the `.properties` files already created: they would have been recycled. The most ambituos idea was, however, to deploy the JavaScript project to Github pages. This is not possible with thymeleaf since it needs a server running at all times, but with JavaScript running the in client... it was perfect. To access the database, I planned to use SQL.js @sql-js and #sqlite() @sqlite.

/ CSS frameworks: We all know CSS is awesome and very powerful, however, as is the case with many technologies, its usage in a raw form is often negleted: as no one dares to write in #text(font: "New Computer Modern")[plain] #TeX because #LaTeX exists, software like Hibernate abstract the SQL from the developer, the same applies to CSS. In the wild there are many frameworks -- Tailwind-CSS, Sass just to name a few. We wanted to have our fair share and use Bulma @bulma; in the end, we wrote everything ourselves.

== Optimizations

/ The OG database : The first database implementation was created with a different logic than the one we ended up with. I, thought that the tracks were a common pool, such as all the tracks of a streaming service, and then each user could select some among them. In this way, if a user wanted to upload a track and it was already been uploaded by someone else, the server would have just linked that track to the current user -- this was to optimize track storage and forbid permit duplicates.

To support such a logic, there used to exist a `track`and a `user_tracks` tables. This allowed us to perform some other optimization: we had thought about of creating a trigger in the database: it would have deleted a track from the corresponding table if that track wasn't associated with at least a user (in the ER diagram it was a weak entity, that is it existed only as long as there was a link).

The issue was quite simple... the submission didn't specify this; instead, every user has their tracks. They can be the same exact files of another user -- pretty much like how a cloud service works. And that's how the project works. Still, we couldn't just let the user upload track at will without some checks. And that trigger became the checksum pipeline.

/ Missing hashing: One could argue: "You went above and beyond to ensure the user doesn't upload the same exact file multiple times, yet you don't even hash the passwords". And you would be right. We wanted to do that by leveraging the power of Password4J @password4j, but once again the specification didn't ask for it and so... we had other features to work on.

/ Connection pooling : Another important optimization technique is #link("https://en.wikipedia.org/wiki/Connection_pool")[connection pooling]: to put it simply, instead of opening every time a new connection to the database -- which is the most expensive operation database-wise -- there is a pool of reusable connections, that are always open. This way, the database is accessed once and then the query are performed by the same connections. The library of choice was HikariCP @hikaricp.

/ ORM: The proper (or #emph[elegant]) way interact with the database isn't by directly writing raw SQL code but by using APIs written for this very reason. There are many examples in web techologies -- such as jQuery -- though for the Java programming language, pioneer of the Object-Oriented Programming paradigma, there is a more potent concept: #link("https://en.wikipedia.org/wiki/Object-relational_mapping")[Object Relational Mapping (ORM)]. As the name suggests, a relational object is mapped to a Java object. By using Hibernate @hibernate a table could have mapped 1:1 to a class and its attributes: every query -- select, insert, delete... -- can be performed through it with commits, transactions and so on.

Probably the saddest turn back was not being able to use the Spring Boot framework @spring-boot, which is commonly used. It's a framework to create production-level applications: as such, it surely is useful to know, whatever the case. Also, during research of how thymeleaf operates, it was basically always paired with Spring Boot.
