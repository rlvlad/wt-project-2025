package it.polimi.tiw25.js.filters;

import it.polimi.tiw25.js.DAO.TrackDAO;
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
 * Filter to check if the selected tracks belong to the currently logged-in User.
 */
public class SelectedTracksChecker extends HttpFilter {
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
        String[] selectedTracksIds = req.getParameterValues("selectedTracks");
        TrackDAO trackDAO = new TrackDAO(connection);

        if (selectedTracksIds != null) {
            for (String trackId : selectedTracksIds) {
                boolean isOwner;
                try {
                    isOwner = trackDAO.checkTrackOwner(Integer.parseInt(trackId), user);
                } catch (SQLException e) {
                    e.printStackTrace();
                    res.sendError(HttpServletResponse.SC_BAD_REQUEST);
                    return;
                } catch (NumberFormatException e) {
                    res.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid trackId");
                    return;
                }

                if (!isOwner) {
                    res.sendError(HttpServletResponse.SC_BAD_REQUEST, "Track does not exist");
                    return;
                }
            }
        }
        filterChain.doFilter(req, res);
    }

    @Override
    public void destroy() {
        ConnectionHandler.closeConnection(connection);
    }
}
