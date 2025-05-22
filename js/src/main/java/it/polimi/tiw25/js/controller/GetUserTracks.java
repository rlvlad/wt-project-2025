package it.polimi.tiw25.js.controller;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import it.polimi.tiw25.js.DAO.PlaylistDAO;
import it.polimi.tiw25.js.DAO.TrackDAO;
import it.polimi.tiw25.js.entities.Track;
import it.polimi.tiw25.js.entities.User;
import it.polimi.tiw25.js.utils.ConnectionHandler;
import jakarta.servlet.ServletContext;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.Serial;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.List;

@WebServlet("/GetUserTracks")
public class GetUserTracks extends HttpServlet {
    @Serial
    private static final long serialVersionUID = 1L;
    private Connection connection = null;

    @Override
    public void init() throws ServletException {
        ServletContext context = getServletContext();
        connection = ConnectionHandler.openConnection(context);
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession s = req.getSession();
        User user = (User) s.getAttribute("user");

        TrackDAO trackDAO = new TrackDAO(connection);
        List<Track> userTracks;
        try {
            userTracks = trackDAO.getUserTracks(user);
        } catch (SQLException e) {
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            e.printStackTrace();
            return;
        }

        Gson gson = new GsonBuilder().setDateFormat("yyyy-MM-dd").create();

        String json = gson.toJson(userTracks);
        resp.setContentType("application/json");
        resp.setStatus(HttpServletResponse.SC_OK);
        resp.getWriter().write(json);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        doGet(req, resp);
    }
}
