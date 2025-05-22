package it.polimi.tiw25.js.entities;

import it.polimi.tiw25.js.entities.User;

/**
 * Class that represents a Playlist.
 */
public record Playlist(
        int id,
        String title,
        java.sql.Date creation_date,
        User user
) {
}
