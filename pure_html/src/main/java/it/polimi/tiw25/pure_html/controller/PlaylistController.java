package it.polimi.tiw25.pure_html.controller;

import it.polimi.tiw25.pure_html.DAO.PlaylistDAO;
import it.polimi.tiw25.pure_html.DAO.TrackDAO;
import it.polimi.tiw25.pure_html.entities.Playlist;
import it.polimi.tiw25.pure_html.entities.Track;
import it.polimi.tiw25.pure_html.entities.User;
import jakarta.servlet.ServletContext;
import jakarta.servlet.ServletException;
import jakarta.servlet.UnavailableException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.thymeleaf.TemplateEngine;
import org.thymeleaf.context.WebContext;
import org.thymeleaf.templatemode.TemplateMode;
import org.thymeleaf.templateresolver.WebApplicationTemplateResolver;
import org.thymeleaf.web.servlet.JakartaServletWebApplication;

import java.io.IOException;
import java.io.Serial;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.List;

/**
 * Generates the tracks associated to a Playlist.
 */
@WebServlet("/Playlist")
public class PlaylistController extends HttpServlet {
    @Serial
    private static final long serialVersionUID = 1L;
    private TemplateEngine templateEngine;
    private Connection connection = null;

    @Override
    public void init() throws ServletException {
        try {
            ServletContext context = getServletContext();
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

        ServletContext servletContext = getServletContext();
        JakartaServletWebApplication webApplication = JakartaServletWebApplication.buildApplication(servletContext);
        WebApplicationTemplateResolver templateResolver = new WebApplicationTemplateResolver(webApplication);

        templateResolver.setTemplateMode(TemplateMode.HTML);
        this.templateEngine = new TemplateEngine();
        this.templateEngine.setTemplateResolver(templateResolver);
        templateResolver.setSuffix(".html");
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        JakartaServletWebApplication webApplication = JakartaServletWebApplication.buildApplication(getServletContext());
        WebContext ctx = new WebContext(webApplication.buildExchange(req, resp), req.getLocale());

        HttpSession s = req.getSession();
        User user = (User) s.getAttribute("user");
        Integer playlistId = null;
        try {
            playlistId = Integer.parseInt(req.getParameter("playlistId"));
        } catch (NumberFormatException e) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid playlistId");
            return;
        }
        String trackGroupString = req.getParameter("gr");
        Integer trackGroup = 0;
        if (trackGroupString != null) {
            Integer tmp = Integer.parseInt(trackGroupString);
            if (tmp > 0) {
                trackGroup = tmp;
            }
        }

        String playlistTitle = null;
        PlaylistDAO playlistDAO = new PlaylistDAO(connection);

        try {
            playlistTitle = playlistDAO.getPlaylistTitle(playlistId);
        } catch (SQLException e) {
            e.printStackTrace();
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            return;
        }

        List<Track> playlistTracks = null;
        try {
            playlistTracks = playlistDAO.getTrackGroup(playlistId, trackGroup);
        } catch (SQLException e) {
            e.printStackTrace();
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            return;
        }

        List<Track> addableTracks = null;
        try {
            addableTracks = playlistDAO.getTracksNotInPlaylist(playlistTitle, user.id());
        } catch (SQLException e) {
            e.printStackTrace();
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            return;
        }

        ctx.setVariable("trackGroup", trackGroup);
        ctx.setVariable("playlistId", playlistId);
        ctx.setVariable("playlistTitle", playlistTitle);
        ctx.setVariable("addableTracks", addableTracks);
        ctx.setVariable("playlistTracks", playlistTracks);
        String path = "playlist_page";
        templateEngine.process(path, ctx, resp.getWriter());
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        super.doPost(req, resp);
    }
}
