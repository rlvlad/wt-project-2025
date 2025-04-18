package it.polimi.tiw25.pure_html.DAO;

import it.polimi.tiw25.pure_html.entities.Track;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

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
                resultSet.getDate("year"),
                resultSet.getString("album_title"),
                resultSet.getString("genre"),
                resultSet.getString("image_path"),
                resultSet.getString("path")
        );
    }
}
