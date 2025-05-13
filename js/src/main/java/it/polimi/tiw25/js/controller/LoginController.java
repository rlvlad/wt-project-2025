package it.polimi.tiw25.js.controller;

import it.polimi.tiw25.js.DAO.UserDAO;
import it.polimi.tiw25.js.entities.User;
import it.polimi.tiw25.js.utils.ConnectionHandler;
import jakarta.servlet.ServletContext;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.Serial;
import java.sql.Connection;
import java.sql.SQLException;

@MultipartConfig
@WebServlet("/Login") // access this controller via action="" on the forms
public class LoginController extends HttpServlet {
    @Serial
    private static final long serialVersionUID = 1L;
    private Connection connection = null;

    @Override
    public void init() throws ServletException {
        ServletContext context = getServletContext();
        connection = ConnectionHandler.openConnection(context);
    }

    @Override
    public void doGet(HttpServletRequest req, HttpServletResponse res) throws IOException {
    }

    @Override
    public void doPost(HttpServletRequest req, HttpServletResponse res) throws IOException {
        String nickname = req.getParameter("nickname");
        String password = req.getParameter("password");

        UserDAO userDAO = new UserDAO(connection);
        User schrondingerUser = null;
        try {
            schrondingerUser = userDAO.checkUser(nickname, password);
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }


        if (schrondingerUser != null) {
            req.getSession().setAttribute("user", schrondingerUser);
            res.setStatus(HttpServletResponse.SC_OK);
        } else {
            res.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            res.getWriter().println("Invalid credentials");
        }
    }

    @Override
    public void destroy() {
        ConnectionHandler.closeConnection(connection);
    }
}