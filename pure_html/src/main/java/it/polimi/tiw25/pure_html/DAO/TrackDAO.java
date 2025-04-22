package it.polimi.tiw25.pure_html.DAO;

import it.polimi.tiw25.pure_html.entities.Track;
import it.polimi.tiw25.pure_html.entities.User;

import java.sql.*;

public class TrackDAO {
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
                 SELECT track_id, title, image_path, album_title, artist, year, genre, path
                 FROM track
                 WHERE track_id = ?
                """);

        preparedStatement.setInt(1, trackId);
        ResultSet resultSet = preparedStatement.executeQuery();

        resultSet.next();

        return new Track(
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
        preparedStatement.setString(7, track.album_image_path());
        preparedStatement.setString(8, track.song_path());
        preparedStatement.setString(9, track.song_checksum());
        preparedStatement.setString(10, track.image_checksum());

        preparedStatement.executeQuery();
        ResultSet rs = preparedStatement.getGeneratedKeys();
        if (rs.next())
            return rs.getInt(1);
        return null;
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
        if (!result.isBeforeFirst())
            return null;
        else {
            result.next();
            return result.getString("song_path");
        }
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
        if (!result.isBeforeFirst())
            return null;
        else {
            result.next();
            return result.getString("image_path");
        }
    }
}
