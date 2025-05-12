package it.polimi.tiw25.js.filters;

import it.polimi.tiw25.js.DAO.PlaylistDAO;
import it.polimi.tiw25.js.entities.User;
import it.polimi.tiw25.js.utils.ConnectionHandler;
import jakarta.servlet.FilterChain;
import jakarta.servlet.FilterConfig;
import jakarta.servlet.ServletContext;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.Serial;
import java.sql.Connection;
import java.sql.SQLException;

/**
 * Filter to check if the requested playlist belongs to the currently logged-in User.
 */
public class PlaylistChecker extends HttpFilter {
    @Serial
    private static final long serialVersionUID = 1L;
    private Connection connection = null;

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        ServletContext context = filterConfig.getServletContext();
        connection = ConnectionHandler.openConnection(context);
    }

    @Override
    public void doFilter(HttpServletRequest req, HttpServletResponse res, FilterChain filterChain) throws IOException, ServletException {
        HttpSession s = req.getSession();
        User user = (User) s.getAttribute("user");
        PlaylistDAO playlistDAO = new PlaylistDAO(connection);
        int playlistId;

        boolean result;
        try {
            playlistId = Integer.parseInt(req.getParameter("playlistId"));
            if (playlistId < 0)
                throw new NumberFormatException();
            result = playlistDAO.checkPlaylistOwner(playlistId, user);
        } catch (SQLException e) {
            e.printStackTrace();
            res.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        } catch (NumberFormatException e) {
            res.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid playlistId");
            return;
        }

        if (!result) {
            res.sendError(HttpServletResponse.SC_BAD_REQUEST, "Playlist does not exist");
            return;
        }


        filterChain.doFilter(req, res);
    }

    @Override
    public void destroy() {
        ConnectionHandler.closeConnection(connection);
    }
}
