package it.polimi.tiw25.pure_html.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import it.polimi.tiw25.pure_html.DAO.PlaylistDAO;
import it.polimi.tiw25.pure_html.DAO.TrackDAO;
import it.polimi.tiw25.pure_html.entities.Playlist;
import it.polimi.tiw25.pure_html.entities.Track;
import it.polimi.tiw25.pure_html.entities.User;
import it.polimi.tiw25.pure_html.utils.ConnectionHandler;
import it.polimi.tiw25.pure_html.utils.TemplateEngineHandler;
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
import org.thymeleaf.web.servlet.JakartaServletWebApplication;

import java.io.IOException;
import java.io.Serial;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.List;

@WebServlet("/HomePage")
public class HomepageController extends HttpServlet {
    @Serial
    private static final long serialVersionUID = 1L;
    private TemplateEngine templateEngine;
    private Connection connection = null;
    private List<String> genres;

    @Override
    public void init() throws ServletException {
        ServletContext context = getServletContext();
        connection = ConnectionHandler.openConnection(context);
        templateEngine = TemplateEngineHandler.getTemplateEngine(context);
        try {
            ObjectMapper objectMapper = new ObjectMapper();
            genres = List.of(objectMapper.readValue(this.getClass().getClassLoader().getResourceAsStream("genres.json"), String[].class));
        } catch (IOException e) {
            e.printStackTrace();
            throw new UnavailableException("Couldn't load genres");
        }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws IOException {
        JakartaServletWebApplication webApplication = JakartaServletWebApplication.buildApplication(getServletContext());
        WebContext ctx = new WebContext(webApplication.buildExchange(req, res), req.getLocale());

        HttpSession s = req.getSession();
        User user = (User) s.getAttribute("user");

        PlaylistDAO playlistDAO = new PlaylistDAO(connection);

        List<Playlist> playlists = null;
        try {
            playlists = playlistDAO.getUserPlaylists(user);
        } catch (SQLException e) {
            res.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            e.printStackTrace();
            return;
        }

        TrackDAO trackDAO = new TrackDAO(connection);
        List<Track> userTracks = null;
        try {
            userTracks = trackDAO.getUserTracks(user);
        } catch (SQLException e) {
            res.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            e.printStackTrace();
            return;
        }

        String duplicateTrack = req.getParameter("duplicateTrack");
        if (duplicateTrack != null && duplicateTrack.equals("true")) {
            ctx.setVariable("duplicateTrack", "true");
        }
        String duplicatePlaylist = req.getParameter("duplicatePlaylist");
        if (duplicatePlaylist != null && duplicatePlaylist.equals("true")) {
            ctx.setVariable("duplicatePlaylist", "true");
        }

        ctx.setVariable("userTracks", userTracks);
        ctx.setVariable("playlists", playlists);
        ctx.setVariable("genres", genres);
        templateEngine.process("home_page.html", ctx, res.getWriter());
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        doGet(req, res);
    }

    @Override
    public void destroy() {
        ConnectionHandler.closeConnection(connection);
    }
}