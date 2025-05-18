package it.polimi.tiw25.js.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import it.polimi.tiw25.js.DAO.PlaylistDAO;
import it.polimi.tiw25.js.DAO.TrackDAO;
import it.polimi.tiw25.js.entities.Playlist;
import it.polimi.tiw25.js.entities.Track;
import it.polimi.tiw25.js.entities.User;
import it.polimi.tiw25.js.utils.ConnectionHandler;
import jakarta.servlet.ServletContext;
import jakarta.servlet.ServletException;
import jakarta.servlet.UnavailableException;
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

@WebServlet("/HomePage")
public class HomepageController extends HttpServlet {
    @Serial
    private static final long serialVersionUID = 1L;
    private Connection connection = null;
    private List<String> genres;

    @Override
    public void init() throws ServletException {
        ServletContext context = getServletContext();
        connection = ConnectionHandler.openConnection(context);
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
        HttpSession s = req.getSession();
        User user = (User) s.getAttribute("user");

        PlaylistDAO playlistDAO = new PlaylistDAO(connection);

        List<Playlist> playlists;
        try {
            playlists = playlistDAO.getUserPlaylists(user);
        } catch (SQLException e) {
            res.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            e.printStackTrace();
            return;
        }

        Gson gson = new GsonBuilder().setDateFormat("yyyy-MM-dd").create();

        String playlists_json = gson.toJson(playlists);

        res.setContentType("application/json");
        res.setStatus(HttpServletResponse.SC_OK);
        // write JSON data to response
        res.getWriter().write(playlists_json);
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