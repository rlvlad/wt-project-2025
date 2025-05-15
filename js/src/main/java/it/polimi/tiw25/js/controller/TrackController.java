package it.polimi.tiw25.js.controller;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import it.polimi.tiw25.js.DAO.TrackDAO;
import it.polimi.tiw25.js.entities.Track;
import it.polimi.tiw25.js.entities.User;
import it.polimi.tiw25.js.utils.ConnectionHandler;
import it.polimi.tiw25.js.utils.TemplateEngineHandler;
import jakarta.servlet.ServletContext;
import jakarta.servlet.ServletException;
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

@WebServlet("/Track")
public class TrackController extends HttpServlet {
    @Serial
    private static final long serialVersionUID = 1L;
    private TemplateEngine templateEngine;
    private Connection connection = null;

    @Override
    public void init() throws ServletException {
        ServletContext context = getServletContext();
        connection = ConnectionHandler.openConnection(context);
        templateEngine = TemplateEngineHandler.getTemplateEngine(context);
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        JakartaServletWebApplication webApplication = JakartaServletWebApplication.buildApplication(getServletContext());
        WebContext ctx = new WebContext(webApplication.buildExchange(req, resp), req.getLocale());

        HttpSession s = req.getSession();
        User user = (User) s.getAttribute("user");
        int trackId = Integer.parseInt(req.getParameter("track_id"));

        TrackDAO trackDAO = new TrackDAO(connection);
        Track track = null;
        try {
            track = trackDAO.getTrackById(trackId);
        } catch (SQLException e) {
            e.printStackTrace();
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            return;
        }

        Gson gson = new GsonBuilder().setDateFormat("yyyy-MM-dd").create();

        String track_json = gson.toJson(track);

        // write JSON data to response
        resp.getWriter().write(track_json);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        super.doPost(req, resp);
    }


    @Override
    public void destroy() {
        ConnectionHandler.closeConnection(connection);
    }
}