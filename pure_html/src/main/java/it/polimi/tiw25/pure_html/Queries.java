package it.polimi.tiw25.pure_html;

/**
 * Utility class to manage all queries from the same place.
 */
public class Queries {
    // Checks
    public static final String CHECK_USER = "SELECT * FROM user WHERE nickname = ? AND password = ?";

    // Insertions
    public static final String ADD_USER = "INSERT INTO user (nickname, password, name, surname) VALUES (?, ?, ?, ?)";

}
