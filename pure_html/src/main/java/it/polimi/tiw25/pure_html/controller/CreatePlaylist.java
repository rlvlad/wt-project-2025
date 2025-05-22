package it.polimi.tiw25.pure_html.controller;

import it.polimi.tiw25.pure_html.DAO.PlaylistDAO;
import it.polimi.tiw25.pure_html.entities.Playlist;
import it.polimi.tiw25.pure_html.entities.User;
import it.polimi.tiw25.pure_html.utils.ConnectionHandler;
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
import java.sql.SQLIntegrityConstraintViolationException;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/CreatePlaylist")
public class CreatePlaylist extends HttpServlet {
    @Serial
    private static final long serialVersionUID = 1L;
    private Connection connection = null;
    User user;

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
        PlaylistDAO playlistDAO = new PlaylistDAO(connection);
        user = (User) req.getSession().getAttribute("user");

        String playlistTitle = req.getParameter("playlistTitle");
        Playlist playlist = new Playlist(0, playlistTitle, null, user);

        String[] selectedTracksStringIds = req.getParameterValues("selectedTracks");
        List<Integer> selectedTracksIds = new ArrayList<>();
        if (selectedTracksStringIds != null) {
            for (String id : selectedTracksStringIds) {
                selectedTracksIds.add(Integer.parseInt(id));
            }
        }

        if (playlistTitle == null || playlistTitle.isEmpty()) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Playlist title not valid");
            return;
        }
        try {
            Integer playlistId = null;
            playlistId = playlistDAO.createPlaylist(playlist);
            if (!selectedTracksIds.isEmpty())
                playlistDAO.addTracksToPlaylist(selectedTracksIds, playlistId);
        } catch (SQLIntegrityConstraintViolationException e) {
            resp.sendRedirect(getServletContext().getContextPath() + "/HomePage?duplicatePlaylist=true#create-playlist");
            return;
        } catch (SQLException e) {
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error while creating playlist");
            e.printStackTrace();
            return;
        }
        resp.sendRedirect(getServletContext().getContextPath() + "/HomePage");
    }

    @Override
    public void destroy() {
        ConnectionHandler.closeConnection(connection);
    }
}