package it.polimi.tiw25.js.controller;

import it.polimi.tiw25.js.DAO.PlaylistDAO;
import it.polimi.tiw25.js.utils.ConnectionHandler;
import jakarta.servlet.ServletConfig;
import jakarta.servlet.ServletContext;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.Serial;
import java.sql.Connection;
import java.sql.SQLException;

/**
 * Updates the Track(s) order in a given Playlist.
 */
@WebServlet("/TrackReordering")
public class TrackReordering extends HttpServlet {
    @Serial
    private static final long serialVersionUID = 1L;
    private Connection connection = null;

    @Override
    public void init(ServletConfig config) throws ServletException {
        ServletContext context = getServletContext();
        connection = ConnectionHandler.openConnection(context);
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        super.doGet(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        int playlistId = Integer.parseInt(req.getParameter("playlistId"));
        int trackId = Integer.parseInt(req.getParameter("trackId"));
        int newOrder = Integer.parseInt(req.getParameter("newOrder"));

        PlaylistDAO playlistDAO = new PlaylistDAO(connection);

        try {
            playlistDAO.updateTrackOrder(trackId, newOrder, playlistId);
        } catch (SQLException e) {
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Couldn't update track order.");
            e.printStackTrace();
        }
    }
}
