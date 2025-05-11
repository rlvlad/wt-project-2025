package it.polimi.tiw25.pure_html.DAO;

import it.polimi.tiw25.pure_html.entities.User;
import jakarta.ws.rs.ClientErrorException;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class UserDAO implements DAO {
    private final Connection connection;

    public UserDAO(Connection connection) {
        this.connection = connection;
    }

    /**
     * Checks if there is a user with matching credentials is in the database. If true, then returns a User object with the data retrieved.
     *
     * @param nickname nickname to check
     * @param password password to check
     * @return If the user exists, a User; else null
     * @throws SQLException
     * @see User
     */
    public User checkUser(String nickname, String password) throws SQLException {
        PreparedStatement statement = connection.prepareStatement("SELECT * FROM user WHERE nickname = ? AND password = ?");

        statement.setString(1, nickname);
        statement.setString(2, password);

        ResultSet result = statement.executeQuery();

        User user = null;
        if (result.isBeforeFirst()) {
            // the user exists
            result.next();
            user = new User(
                    result.getInt("user_id"),
                    result.getString("nickname"),
                    result.getString("password"),
                    result.getString("name"),
                    result.getString("surname")
            );
        }

        close(result, statement);
        return user;
    }

    /**
     * Adds User to the database.
     *
     * @param user User to be added to the database
     * @return false if the user is not added to the database
     */
    public boolean addUser(User user) {
        PreparedStatement statement = null;
        try {
            statement = connection.prepareStatement(
                    "INSERT INTO user(nickname, password, name, surname)VALUES( ?, ?, ?, ?)"
            );

            statement.setString(1, user.nickname());
            statement.setString(2, user.password());
            statement.setString(3, user.name());
            statement.setString(4, user.surname());

            statement.executeUpdate();
        } catch (SQLException e) {
            // the user could not be added
            System.out.println(e.getMessage());
            return false;
        } finally {
            if (statement != null) {
                close(statement);
            }
        }

        // the operation succeded
        return true;
    }
}
