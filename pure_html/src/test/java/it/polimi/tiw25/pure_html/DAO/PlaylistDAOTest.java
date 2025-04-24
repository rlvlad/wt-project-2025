package it.polimi.tiw25.pure_html.DAO;

import it.polimi.tiw25.pure_html.entities.Playlist;
import it.polimi.tiw25.pure_html.entities.Track;
import it.polimi.tiw25.pure_html.entities.User;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.text.DateFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.fail;

class PlaylistDAOTest {
    Connection connection;
    PlaylistDAO playlistDAO;
    User user;
    String playlistTitle = "Ginger Turmeric Tea";
    int playlistId = 19;

    @BeforeEach
    void setUp() throws Exception {
        final String DATABASE = "tiw";
        final String USER = "tiw";
        final String PASSWORD = "password";
        Connection connection = null;

        try {
            Class.forName("org.mariadb.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            fail("Driver not found");
            e.printStackTrace();
        }

        try {
            connection = DriverManager.getConnection("jdbc:mariadb://localhost:3306/" + DATABASE, USER, PASSWORD);
        } catch (Exception e) {
            fail("Connection failed");
            e.printStackTrace();
        }

        playlistDAO = new PlaylistDAO(connection);
        user = new User(
                86,
                "Goldie",
                "E8*00a!#**%#o",
                "Golda",
                "Harburtson"
        );
    }

    @Test
    void getUserPlaylists() throws SQLException {
        List<Playlist> playlists = playlistDAO.getUserPlaylists(user);

        assertEquals(playlistTitle, playlists.getFirst().title());

        DateFormat df = new SimpleDateFormat("yyyy-MM-dd");
        java.sql.Date sqlDate;
        try {
            sqlDate = new java.sql.Date(df.parse("2024-09-18").getTime());
        } catch (ParseException e) {
            throw new RuntimeException(e);
        }

        assertEquals(sqlDate, playlists.getFirst().creation_date());
    }

    @Test
    void getPlaylistTracksByTitle() throws SQLException {
        List<Track> tracks = playlistDAO.getPlaylistTracksByTitle(playlistTitle, user);
        assertEquals("Reversible Swimming Pool Lounger", tracks.getFirst().title());
    }

    @Test
    void getPlaylistTracksById() throws SQLException {
        List<Track> tracks = playlistDAO.getPlaylistTracksById(playlistId);
        assertEquals("Reversible Swimming Pool Lounger", tracks.getFirst().title());
    }

    @Test
    void getPlaylistTitle() throws SQLException {
        String expected = playlistDAO.getPlaylistTitle(playlistId);
        assertEquals(playlistTitle, expected);
    }

    @Test
    void createPlaylist() {
    }

    @Test
    void deletePlaylist() {
    }

    @Test
    void addTracksToPlaylist() {
    }

    @Test
    void removeTrackFromPlaylist() {
    }
}