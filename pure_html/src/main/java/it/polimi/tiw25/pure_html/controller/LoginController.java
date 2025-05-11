package it.polimi.tiw25.pure_html.controller;

import it.polimi.tiw25.pure_html.DAO.UserDAO;
import it.polimi.tiw25.pure_html.entities.User;
import it.polimi.tiw25.pure_html.utils.ConnectionHandler;
import it.polimi.tiw25.pure_html.utils.TemplateEngineHandler;
import jakarta.servlet.ServletContext;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.thymeleaf.TemplateEngine;
import org.thymeleaf.context.WebContext;
import org.thymeleaf.web.servlet.JakartaServletWebApplication;

import java.io.IOException;
import java.io.Serial;
import java.sql.Connection;
import java.sql.SQLException;

@WebServlet("/Login") // access this controller via action="" on the forms
public class LoginController extends HttpServlet {
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
    public void doGet(HttpServletRequest req, HttpServletResponse res) throws IOException {
        JakartaServletWebApplication webApplication = JakartaServletWebApplication.buildApplication(getServletContext());
        WebContext ctx = new WebContext(webApplication.buildExchange(req, res), req.getLocale());
        String error = req.getParameter("error");
        if (error != null && error.equals("true")) {
            ctx.setVariable("error", "true");
        }

        templateEngine.process("index.html", ctx, res.getWriter());
    }

    @Override
    public void doPost(HttpServletRequest req, HttpServletResponse res) throws IOException {
        String nickname = req.getParameter("nickname");
        String password = req.getParameter("password");

        UserDAO userDAO = new UserDAO(connection);
        User schrondingerUser = null;
        try {
            schrondingerUser = userDAO.checkUser(nickname, password);
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }

        req.getSession().setAttribute("user", schrondingerUser);

        if (schrondingerUser != null) {
            res.sendRedirect(getServletContext().getContextPath() + "/HomePage");
        } else {
            res.sendRedirect(getServletContext().getContextPath() + "/Login?error=true");
        }
    }

    @Override
    public void destroy() {
        ConnectionHandler.closeConnection(connection);
    }
}