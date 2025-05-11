package it.polimi.tiw25.pure_html.controller;

import it.polimi.tiw25.pure_html.DAO.PlaylistDAO;
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

@WebServlet("/AddTracks")
public class AddTracksToPlaylist extends HttpServlet {
    @Serial
    private static final long serialVersionUID = 1L;
    private Connection connection = null;
    User user;

    public void init() throws ServletException {
        ServletContext context = getServletContext();
        connection = ConnectionHandler.openConnection(context);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        PlaylistDAO playlistDAO = new PlaylistDAO(connection);
        user = (User) req.getSession().getAttribute("user");
        String[] selectedTracksStringIds = req.getParameterValues("selectedTracks");
        List<Integer> selectedTracksIds = new ArrayList<>();
        if (selectedTracksStringIds != null) {
            for (String id : selectedTracksStringIds) {
                    selectedTracksIds.add(Integer.parseInt(id));
            }
        }

        int playlistId;
        try {
            playlistId = Integer.parseInt(req.getParameter("playlistId"));
        } catch (NumberFormatException e) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid playlistId");
            return;
        }

        try {
            playlistDAO.addTracksToPlaylist(selectedTracksIds, playlistId);
        } catch (SQLIntegrityConstraintViolationException e) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "One or more tracks were already added: operation aborted");
            return;
        } catch (SQLException e) {
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error while adding tracks");
            e.printStackTrace();
            return;
        }

        resp.sendRedirect(getServletContext().getContextPath() + "/Playlist?playlistId=" + playlistId);
    }

    @Override
    public void destroy() {
        ConnectionHandler.closeConnection(connection);
    }
}