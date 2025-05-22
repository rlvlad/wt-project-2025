package it.polimi.tiw25.pure_html.utils;

import jakarta.servlet.ServletContext;
import org.thymeleaf.TemplateEngine;
import org.thymeleaf.templatemode.TemplateMode;
import org.thymeleaf.templateresolver.WebApplicationTemplateResolver;
import org.thymeleaf.web.servlet.JakartaServletWebApplication;

public class TemplateEngineHandler {
    public static TemplateEngine getTemplateEngine(ServletContext context) {
        TemplateEngine templateEngine = new TemplateEngine();
        JakartaServletWebApplication webApplication = JakartaServletWebApplication.buildApplication(context);
        WebApplicationTemplateResolver templateResolver = new WebApplicationTemplateResolver(webApplication);

        templateResolver.setTemplateMode(TemplateMode.HTML);
        templateEngine.setTemplateResolver(templateResolver);
        templateResolver.setSuffix(".html");
        return templateEngine;
    }
}
