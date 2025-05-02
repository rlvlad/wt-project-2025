package it.polimi.tiw25.pure_html.filters;

import it.polimi.tiw25.pure_html.DAO.PlaylistDAO;
import it.polimi.tiw25.pure_html.entities.User;
import jakarta.servlet.*;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.io.Serial;
import java.sql.Connection;
import java.sql.DriverManager;
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
        try {
            ServletContext context = filterConfig.getServletContext();
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
    public void doFilter(HttpServletRequest req, HttpServletResponse res, FilterChain filterChain) throws IOException, ServletException {

        HttpSession s = req.getSession();
        User user = (User) s.getAttribute("user");
        String playlistId = req.getParameter("playlistId");
        PlaylistDAO playlistDAO = new PlaylistDAO(connection);

        boolean result;
        try {
            result = playlistDAO.checkPlaylistOwner(Integer.parseInt(playlistId), user);
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
        super.destroy();
    }
}
