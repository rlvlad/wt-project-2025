package it.polimi.tiw25.pure_html.filters;

import it.polimi.tiw25.pure_html.DAO.TrackDAO;
import it.polimi.tiw25.pure_html.entities.User;
import it.polimi.tiw25.pure_html.utils.ConnectionHandler;
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
 * Filter to check if the requested track belongs to the currently logged-in User.
 */
public class TrackChecker extends HttpFilter {
    @Serial
    private static final long serialVersionUID = 1L;
    private Connection connection = null;

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        ServletContext context = filterConfig.getServletContext();
        connection = ConnectionHandler.openConnection(context);
    }

    @Override
    public void doFilter(HttpServletRequest req, HttpServletResponse res, FilterChain chain) throws IOException, ServletException {
        HttpSession s = req.getSession();
        User user = (User) s.getAttribute("user");
        TrackDAO trackDAO = new TrackDAO(connection);
        int trackId;

        try {
            trackId = Integer.parseInt(req.getParameter("track_id"));
            if (trackId < 0)
                throw new NumberFormatException();
        } catch (NumberFormatException e) {
            res.sendError(HttpServletResponse.SC_NOT_FOUND, "Invalid trackId");
            return;
        }

        boolean isOwner = false;
        try {
            isOwner = trackDAO.checkTrackOwner(trackId, user);
        } catch (SQLException e) {
            e.printStackTrace();
            res.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            return;
        }

        if (!isOwner) {
            res.sendError(HttpServletResponse.SC_NOT_FOUND, "Track does not exist");
            return;
        }

        chain.doFilter(req, res);
    }

    @Override
    public void destroy() {
        ConnectionHandler.closeConnection(connection);
    }
}
