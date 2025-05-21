package it.polimi.tiw25.js.controller;

import com.google.gson.Gson;
import it.polimi.tiw25.js.DAO.PlaylistDAO;
import it.polimi.tiw25.js.utils.ConnectionHandler;
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
import java.util.List;

/**
 * Updates the Track(s) order in a given Playlist.
 */
@WebServlet("/TrackReorder")
public class TrackReorder extends HttpServlet {
    @Serial
    private static final long serialVersionUID = 1L;
    private Connection connection = null;

    @Override
    public void init() throws ServletException {
        ServletContext context = getServletContext();
        connection = ConnectionHandler.openConnection(context);
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        doPost(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Gson gson = new Gson();
        RequestData requestData = null;
        try {
            requestData = gson.fromJson(req.getReader(), RequestData.class);
        } catch (Exception e) {
            e.printStackTrace();
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            return;
        }

        System.out.println("sussy");
        PlaylistDAO playlistDAO = new PlaylistDAO(connection);

        try {
            playlistDAO.updateTrackOrder(requestData.trackIds(), requestData.playlistId());
        } catch (SQLException e) {
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            resp.setContentType("plain/text");
            resp.getWriter().println("Server error");
            e.printStackTrace();
            return;
        }
        resp.setStatus(HttpServletResponse.SC_OK);
        resp.setContentType("plain/text");
        resp.getWriter().println("Update successful");
    }

    @Override
    public void destroy() {
        ConnectionHandler.closeConnection(connection);
    }
}

record RequestData(List<Integer> trackIds, Integer playlistId) {
}