package it.polimi.tiw25.pure_html.DAO;

import it.polimi.tiw25.pure_html.entities.Track;
import it.polimi.tiw25.pure_html.entities.User;
import jakarta.ws.rs.ClientErrorException;
import jakarta.ws.rs.core.Response;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class TrackDAO implements DAO {
    private Connection connection;

    public TrackDAO(Connection connection) {
        this.connection = connection;
    }

    /**
     * Get a Track by its primary key, the ID:
     *
     * @param trackId
     * @return
     * @throws SQLException
     */
    public Track getTrackById(int trackId) throws SQLException {
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
                 WHERE track_id = ?
                """);

        preparedStatement.setInt(1, trackId);
        ResultSet resultSet = preparedStatement.executeQuery();

        resultSet.next();

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

        close(resultSet, preparedStatement);
        return track;
    }

    public List<Track> getUserTracks(User user) throws SQLException {
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
                 WHERE user_id = ?
                 ORDER BY artist ASC, YEAR ASC, title ASC
                """);
        preparedStatement.setInt(1, user.id());
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


    public Integer addTrack(Track track, User user) throws SQLException {
        PreparedStatement preparedStatement = connection.prepareStatement("""
                INSERT INTO track (user_id, title, artist, year, album_title, genre, image_path, song_path, song_checksum, image_checksum)
                VALUES (?,?,?,?,?,?,?,?,?,?)
                """, Statement.RETURN_GENERATED_KEYS);

        preparedStatement.setInt(1, user.id());
        preparedStatement.setString(2, track.title());
        preparedStatement.setString(3, track.artist());
        preparedStatement.setInt(4, track.year());
        preparedStatement.setString(5, track.album_title());
        preparedStatement.setString(6, track.genre());
        preparedStatement.setString(7, track.image_path());
        preparedStatement.setString(8, track.song_path());
        preparedStatement.setString(9, track.song_checksum());
        preparedStatement.setString(10, track.image_checksum());

        preparedStatement.executeQuery();
        ResultSet rs = preparedStatement.getGeneratedKeys();

        Integer id = null;
        if (rs.next())
            id = rs.getInt(1);

        close(preparedStatement);
        return id;
    }

    /**
     * @param checksum Music file checksum
     * @return String containing the file song_path if present; else null
     * @throws SQLException
     */
    public String isTrackFileAlreadyPresent(String checksum) throws SQLException {
        PreparedStatement preparedStatement = connection.prepareStatement("""
                SELECT song_path FROM track WHERE song_checksum = ?
                """);
        preparedStatement.setString(1, checksum);
        ResultSet result = preparedStatement.executeQuery();

        String path = null;
        if (result.isBeforeFirst()) {
            result.next();
            path = result.getString("song_path");
        }

        close(result, preparedStatement);
        return path;
    }

    /**
     * @param checksum Image file checksum
     * @return String containing the file song_path if present; else null
     * @throws SQLException
     */
    public String isImageFileAlreadyPresent(String checksum) throws SQLException {
        PreparedStatement preparedStatement = connection.prepareStatement("""
                SELECT image_path FROM track WHERE image_checksum = ?
                """);
        preparedStatement.setString(1, checksum);
        ResultSet result = preparedStatement.executeQuery();

        String path = null;
        if (result.isBeforeFirst()) {
            result.next();
            path = result.getString("image_path");
        }
        close(result, preparedStatement);
        return path;
    }

    /**
     * Checks if the requested Track actually belongs to the currently logged-in User.
     *
     * @param track_id track_id of the Track to check
     * @param user     user of which to check the ownership status
     * @return true if the tracks belongs to the User; false otherwise
     * @throws SQLException
     */
    public boolean checkTrackOwner(int track_id, User user) throws SQLException {
        PreparedStatement preparedStatement = connection.prepareStatement("""
                 SELECT track_id,
                        user_id
                 FROM track NATURAL JOIN user
                 WHERE track_id = ?
                """);

        preparedStatement.setInt(1, track_id);
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
