#import "../lib.typ": *

= Project submission breakdown<project-breakdown>

== Database logic

#let db_legend = (
  entity("Entity"),
  attr("Attribute"),
  attr_spec([Attribute \ specification]),
  rel("Relationship"),
)
#legend(db_legend)

Each #entity[user] has a #attr[username], #attr[password], #attr[name] and #attr[surname]. Each musical #entity[track] is stored in the database by #attr[title], #attr[image], #attr[album title], #attr[album artist name] (single or group), #attr[album release year], #attr[musical genre] and #attr[file]. Furthermore:

- Suppose the #attr_spec[genres are predetermined] #comment("the user cannot create new genres")
- It is not requested to store the track order within albums
- Suppose each track can belong to a unique album (no compilations)

After the login, the user is able to #rel[create tracks by loading their data and then group them in playlists]. A #entity[playlist] is a #attr_spec[set of chosen tracks from the uploaded ones of the user]. A playlist has a #attr[title], a #attr[creation date] and is #attr[associated to its creator].

#figure(
  placement: bottom,
  scope: "parent",
  image("../misc/er_html.svg", width: 15cm),
  caption: [ER diagram, .],
)<er-diagram>

#figure(
  placement: bottom,
  scope: "parent",
  "",
  caption: [UML diagram.],
)<uml-diagram>

== Behaviour

#let bhr_legend = (
  user_action("User action"),
  server_action("Server action"),
  page("HTML page"),
  element("Page element"),
)
#legend(bhr_legend)

After the login, the user #user_action[accesses] the #page[HOME PAGE] which displays the list of their playlists, ordered by descending creation date; a #element[form to load a track with relative data] and a #element[form to create a new playlist]. The playlist form:

- #server_action[Shows] the list of user tracks ordered by artist name in ascending alphabetic order and by ascending album release date
- The form allows to select one or more tracks

When a user clicks on a playlist in the #page[HOME PAGE], the application loads the #page[PLAYLIST PAGE]; initially, it contains a table with a row and five columns.

- Every cell contains the track's title and album name
- The tracks are ordered from left to right by artist name in ascending alphabetic order and by ascending album release date
- If a playlist contains more than 5 tracks, there are available commands to see the others (in blocks of five)

/ Playlist tracks navigation: If the #page[PLAYLIST PAGE]:

+ Shows the first group and there are subsequent ones, a NEXT button appears on the right side of the row
+ Shows the last group and there are precedent ones, a PREVIOUS button appears on the left side of the row that allows to see the five precedent tracks
+ Shows a block of tracks and there are both subsequent and precedent ones, then on left and the right side appear both previous and next button

/ Track creation: The #page[PLAYLIST PAGE] includes a #element[form that allows to add one or more tracks to the current playlist, if not already present]. This form acts in the same way as the playlist creation form.

After adding a new track to the current playlist, the application #server_action[refresh the page display] from the first block of the playlist (the first 5 tracks). Once a user #user_action[selects the title of a track], the #page[PLAYER PAGE] #server_action[shows] all of the #element[track data] and the #element[audio player].

#figure(
  "",
  placement: bottom,
  scope: "parent",
  caption: [IFML diagram.],
)
