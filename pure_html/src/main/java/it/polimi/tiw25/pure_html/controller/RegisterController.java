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

@WebServlet("/Register")
public class RegisterController extends HttpServlet {
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

        boolean isUserAdded = req.getParameter("isUserAdded") == null || !req.getParameter("isUserAdded").equals("false");

        ctx.setVariable("isUserAdded", isUserAdded);
        templateEngine.process("register.html", ctx, res.getWriter());
    }

    @Override
    public void doPost(HttpServletRequest req, HttpServletResponse res) throws IOException {
        String nickname = req.getParameter("nickname");
        String password = req.getParameter("password");
        String name = req.getParameter("name");
        String surname = req.getParameter("surname");

        UserDAO userDAO = new UserDAO(connection);
        User user = new User(
                0,
                nickname,
                password,
                name,
                surname
        );

        boolean isUserAdded = userDAO.addUser(user);

        if (isUserAdded) {
            res.sendRedirect(getServletContext().getContextPath() + "/Login");
        } else {
            res.sendRedirect(
                    getServletContext().getContextPath() + "/Register?isUserAdded=" + false
            );
        }

    }

    @Override
    public void destroy() {
        ConnectionHandler.closeConnection(connection);
    }
}