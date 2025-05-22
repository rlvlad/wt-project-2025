package it.polimi.tiw25.pure_html.DAO;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

public interface DAO {
    default void close(ResultSet resultSet, Statement statement) {
        try {
            resultSet.close();
            statement.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
    default void close(Statement statement) {
        try {
            statement.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}
