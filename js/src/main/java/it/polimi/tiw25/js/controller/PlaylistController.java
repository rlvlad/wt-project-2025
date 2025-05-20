package it.polimi.tiw25.js.controller;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import it.polimi.tiw25.js.DAO.PlaylistDAO;
import it.polimi.tiw25.js.entities.Track;
import it.polimi.tiw25.js.entities.User;
import it.polimi.tiw25.js.utils.ConnectionHandler;
import jakarta.servlet.ServletContext;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
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

/**
 * Generates the tracks associated to a Playlist.
 */
@WebServlet("/Playlist")
@MultipartConfig
public class PlaylistController extends HttpServlet {
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
        int playlistId = Integer.parseInt(req.getParameter("playlistId"));

        PlaylistDAO playlistDAO = new PlaylistDAO(connection);
        List<Track> playlistTracks;
        try {
            playlistTracks = playlistDAO.getPlaylistTracksById(playlistId);
        } catch (SQLException e) {
            e.printStackTrace();
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            return;
        }

        Gson gson = new GsonBuilder().setDateFormat("yyyy-MM-dd").create();

        String playlistTracks_json = gson.toJson(playlistTracks);

        resp.setContentType("application/json");
        resp.setStatus(HttpServletResponse.SC_OK);
        // write JSON data to response
        resp.getWriter().write(playlistTracks_json);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        doGet(req, resp);
    }

    @Override
    public void destroy() {
        ConnectionHandler.closeConnection(connection);
    }
}