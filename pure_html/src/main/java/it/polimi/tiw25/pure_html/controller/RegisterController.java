package it.polimi.tiw25.pure_html.controller;

import it.polimi.tiw25.pure_html.Queries;
import jakarta.servlet.ServletContext;
import jakarta.servlet.ServletException;
import jakarta.servlet.UnavailableException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.SQLException;

@WebServlet("/Register")
public class RegisterController extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private Connection connection = null;

    @Override
    public void init() throws ServletException {
        try {
            ServletContext context = getServletContext();
            String driver = context.getInitParameter("dbDriver");
            String url = context.getInitParameter("dbUrl");
            String user = context.getInitParameter("dbUser");
            String password = context.getInitParameter("dbPassword");
            Class.forName(driver);
            connection = DriverManager.getConnection(url, user, password);
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
            throw new UnavailableException("Can't load database driver");
        } catch (SQLException e) {
            e.printStackTrace();
            throw new UnavailableException("Couldn't get db connection");
        }
    }

    @Override
    public void doGet(HttpServletRequest req, HttpServletResponse res) throws IOException {

    }

    @Override
    public void doPost(HttpServletRequest req, HttpServletResponse res) throws IOException {
        String nickname = req.getParameter("nickname");
        String password = req.getParameter("password");
        String name = req.getParameter("name");
        String surname = req.getParameter("surname");

        assert nickname != null;
        assert password != null;
        assert name != null;
        assert surname != null;

        try {
            addUser(nickname, password, name, surname);
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }

        res.sendRedirect(getServletContext().getContextPath() + "/index.html");
    }

    /**
     * Checks if user is in the database.
     *
     * @param nickname
     * @param password
     * @throws SQLException
     */
    public void addUser(String nickname, String password, String name, String surname) throws SQLException {
        PreparedStatement statement = connection.prepareStatement(Queries.ADD_USER);

        statement.setString(1, nickname);
        statement.setString(2, password);
        statement.setString(3, name);
        statement.setString(4, surname);

        statement.executeUpdate();
    }
}
