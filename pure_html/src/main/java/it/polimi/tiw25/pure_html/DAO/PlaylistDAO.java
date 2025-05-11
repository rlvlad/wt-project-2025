package it.polimi.tiw25.pure_html.DAO;

import it.polimi.tiw25.pure_html.entities.Playlist;
import it.polimi.tiw25.pure_html.entities.Track;
import it.polimi.tiw25.pure_html.entities.User;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class PlaylistDAO implements DAO {
    private final Connection connection;

    public PlaylistDAO(Connection connection) {
        this.connection = connection;
    }

    /**
     * Retrieve Playlists for a given User.
     *
     * @param user User of which to retrieve the playlists
     * @return List of Playlist
     * @throws SQLException
     */
    public List<Playlist> getUserPlaylists(User user) throws SQLException {
        List<Playlist> playlists = new ArrayList<>();

        PreparedStatement preparedStatement = connection.prepareStatement("""
                SELECT b.playlist_id, b.playlist_title, b.creation_date
                FROM user a NATURAL JOIN playlist b
                WHERE a.nickname = ?
                ORDER BY creation_date DESC
                """);

        preparedStatement.setString(1, user.nickname());
        ResultSet resultSet = preparedStatement.executeQuery();

        while (resultSet.next()) {
            Playlist playlist = new Playlist(
                    resultSet.getInt("playlist_id"),
                    resultSet.getString("playlist_title"),
                    resultSet.getDate("creation_date"),
                    user
            );
            playlists.add(playlist);
        }
        close(resultSet, preparedStatement);
        return playlists;
    }

    public List<Track> getPlaylistTracksByTitle(String playlistTitle, User user) throws SQLException {
        List<Track> tracks = new ArrayList<>();

        PreparedStatement preparedStatement = connection.prepareStatement("""
                 SELECT t.track_id, title, album_title, artist, year, genre, song_checksum, image_checksum, song_path, image_path
                 FROM  playlist a
                     JOIN playlist_tracks b ON a.playlist_id = b.playlist_id
                     JOIN track t on b.track_id = t.track_id
                     JOIN user u on a.user_id = u.user_id
                 WHERE u.nickname = ? AND a.playlist_title = ?
                """);

        preparedStatement.setString(1, user.nickname());
        preparedStatement.setString(2, playlistTitle);
        ResultSet resultSet = preparedStatement.executeQuery();

        while (resultSet.next()) {
            Track track = new Track(
                    resultSet.getInt("track_id"),
                    resultSet.getString("title"),
                    resultSet.getString("artist"),
                    resultSet.getInt("year"),
                    resultSet.getString("album_title"),
                    resultSet.getString("genre"),
                    resultSet.getString("image_path"),
                    resultSet.getString("song_path"),
                    resultSet.getString("song_checksum"),
                    resultSet.getString("image_checksum")
            );
            tracks.add(track);
        }

        close(resultSet, preparedStatement);
        return tracks;
    }

    public List<Track> getPlaylistTracksById(int playlistID) throws SQLException {
        List<Track> tracks = new ArrayList<>();

        PreparedStatement preparedStatement = connection.prepareStatement("""
                 SELECT track_id, title, album_title, artist, year, genre, song_checksum, image_checksum, song_path, image_path
                 FROM track a NATURAL JOIN playlist_tracks b
                 WHERE b.playlist_id = ?
                """);

        preparedStatement.setInt(1, playlistID);
        ResultSet resultSet = preparedStatement.executeQuery();

        while (resultSet.next()) {
            Track track = new Track(
                    resultSet.getInt("track_id"),
                    resultSet.getString("title"),
                    resultSet.getString("artist"),
                    resultSet.getInt("year"),
                    resultSet.getString("album_title"),
                    resultSet.getString("genre"),
                    resultSet.getString("image_path"),
                    resultSet.getString("song_path"),
                    resultSet.getString("song_checksum"),
                    resultSet.getString("image_checksum")
            );
            tracks.add(track);
        }

        close(resultSet, preparedStatement);
        return tracks;
    }

    public List<Track> getTracksNotInPlaylist(String playlistTitle, Integer userId) throws SQLException {
        List<Track> userTracks = new ArrayList<>();
        PreparedStatement preparedStatement = connection.prepareStatement("""
                 SELECT track_id,
                        title,
                        artist,
                        year,
                        album_title,
                        genre,
                        image_path,
                        song_path,
                        song_checksum,
                        image_checksum
                 FROM track
                 WHERE user_id = ? AND track_id not in (
                    SELECT t.track_id
                    FROM playlist p NATURAL JOIN playlist_tracks pt JOIN track t ON t.track_id=pt.track_id
                    WHERE p.playlist_title= ? AND p.user_id = ?
                 )
                 ORDER BY artist ASC, YEAR ASC, title ASC
                """);
        preparedStatement.setInt(1, userId);
        preparedStatement.setString(2, playlistTitle);
        preparedStatement.setInt(3, userId);
        ResultSet resultSet = preparedStatement.executeQuery();
        while (resultSet.next()) {
            Track track = new Track(
                    resultSet.getInt("track_id"),
                    resultSet.getString("title"),
                    resultSet.getString("artist"),
                    resultSet.getInt("year"),
                    resultSet.getString("album_title"),
                    resultSet.getString("genre"),
                    resultSet.getString("image_path"),
                    resultSet.getString("song_path"),
                    resultSet.getString("song_checksum"),
                    resultSet.getString("image_checksum")
            );
            userTracks.add(track);
        }
        close(resultSet, preparedStatement);
        return userTracks;
    }

    public List<Track> getTrackGroup(int playlistId, int groupId) throws SQLException {
        List<Track> tracks = new ArrayList<>();

        PreparedStatement preparedStatement = connection.prepareStatement("""
                 SELECT track_id, title, album_title, artist, year, genre, song_checksum, image_checksum, song_path, image_path
                 FROM track a NATURAL JOIN playlist_tracks b
                 WHERE b.playlist_id = ?
                 ORDER BY artist ASC, YEAR ASC, title ASC
                 OFFSET ? ROWS
                 FETCH NEXT 6 ROWS ONLY
                """);

        preparedStatement.setInt(1, playlistId);
        preparedStatement.setInt(2, groupId * 5);
        ResultSet resultSet = preparedStatement.executeQuery();

        while (resultSet.next()) {
            Track track = new Track(
                    resultSet.getInt("track_id"),
                    resultSet.getString("title"),
                    resultSet.getString("artist"),
                    resultSet.getInt("year"),
                    resultSet.getString("album_title"),
                    resultSet.getString("genre"),
                    resultSet.getString("image_path"),
                    resultSet.getString("song_path"),
                    resultSet.getString("song_checksum"),
                    resultSet.getString("image_checksum")
            );
            tracks.add(track);
        }

        close(resultSet, preparedStatement);
        return tracks;
    }

    public String getPlaylistTitle(int playlistID) throws SQLException {
        PreparedStatement preparedStatement = connection.prepareStatement("""
                        SELECT playlist_title
                        FROM playlist
                        WHERE playlist_id = ?
                """);

        preparedStatement.setInt(1, playlistID);
        ResultSet resultSet = preparedStatement.executeQuery();

        String playlistTitle = null;
        if (resultSet.next()) {
            playlistTitle = resultSet.getString("playlist_title");
        }
        close(resultSet, preparedStatement);
        return playlistTitle;
    }

    /**
     * Create a new Playlist for a given User.
     *
     * @param playlist Playlist to create
     * @throws SQLException
     */
    public Integer createPlaylist(Playlist playlist) throws SQLException {
        PreparedStatement preparedStatement = connection.prepareStatement("""
                INSERT INTO playlist (playlist_title, user_id) VALUES (?,?)
                """, Statement.RETURN_GENERATED_KEYS);
        preparedStatement.setString(1, playlist.title());
        preparedStatement.setInt(2, playlist.user().id());
        preparedStatement.executeQuery();
        ResultSet rs = preparedStatement.getGeneratedKeys();

        Integer playlistID = null;
        if (rs.next())
            playlistID = rs.getInt(1);

        close(rs, preparedStatement);
        return playlistID;
    }


    /**
     * Delete a Playlist. Note this will also delete all associated tracks with that playlist.
     *
     * @param playlist
     * @throws SQLException
     */
    public void deletePlaylist(Playlist playlist) throws SQLException {
    }

    /**
     * Adds a new Track to the given Playlist.
     *
     * @param trackIds
     * @param playlistId
     * @throws SQLException
     */
    public void addTracksToPlaylist(List<Integer> trackIds, Integer playlistId) throws SQLException {
        PreparedStatement preparedStatement = connection.prepareStatement("""
                INSERT INTO playlist_tracks (playlist_id, track_id) VALUES (?,?)
                """);
        preparedStatement.setInt(1, playlistId);
        connection.setAutoCommit(false);
        try {
            for (Integer i : trackIds) {
                preparedStatement.setInt(2, i);
                preparedStatement.executeQuery();
            }
        } catch (SQLIntegrityConstraintViolationException e) {
            connection.rollback();
            throw new SQLIntegrityConstraintViolationException();
        } catch (SQLException e) {
            connection.rollback();
            throw new SQLException();
        } finally {
            connection.setAutoCommit(true);
            close(preparedStatement);
        }
    }


    /**
     * Remove a Track from the given Playlist.
     *
     * @param track
     * @param playlist
     * @throws SQLException
     */
    public void removeTrackFromPlaylist(Track track, Playlist playlist) throws SQLException {
    }

    /**
     * Checks if the requested Playlist actually belongs to the currently logged-in User.
     *
     * @param playlist_id playlist_id of the Playlist to check
     * @param user        user of which to check the ownership status
     * @return true if the tracks belongs to the User; false otherwise
     * @throws SQLException
     */
    public boolean checkPlaylistOwner(int playlist_id, User user) throws SQLException {
        PreparedStatement preparedStatement = connection.prepareStatement("""
                 SELECT playlist_id,
                        user_id
                 FROM playlist NATURAL JOIN user
                 WHERE playlist_id = ?
                """);

        preparedStatement.setInt(1, playlist_id);
        ResultSet resultSet = preparedStatement.executeQuery();
        int userId = user.id();

        boolean result = false;
        if (resultSet.isBeforeFirst()) {
            resultSet.next();
            result = userId == resultSet.getInt("user_id");
        }

        close(resultSet, preparedStatement);
        return result;
    }
}
