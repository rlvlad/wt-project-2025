package it.polimi.tiw25.pure_html.controller;

import it.polimi.tiw25.pure_html.DAO.TrackDAO;
import it.polimi.tiw25.pure_html.entities.Track;
import it.polimi.tiw25.pure_html.entities.User;
import jakarta.servlet.ServletContext;
import jakarta.servlet.ServletException;
import jakarta.servlet.UnavailableException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;
import jakarta.ws.rs.ClientErrorException;
import jakarta.ws.rs.InternalServerErrorException;
import jakarta.ws.rs.ServerErrorException;
import jakarta.ws.rs.core.Response;

import java.io.File;
import java.io.IOException;
import java.io.Serial;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.sql.*;
import java.util.*;
import java.util.function.Function;

@WebServlet("/UploadTrack")
@MultipartConfig
public class UploadTrack extends HttpServlet {
    @Serial
    private static final long serialVersionUID = 1L;
    private Connection connection = null;
    private String relativeOutputFolder;
    private String imageHash;
    private String songHash;
    private User user;
    private Track track;
    private List<File> newFiles;
    private ServletContext context;

    public void init() throws ServletException {
        try {
            context = getServletContext();
            String driver = context.getInitParameter("dbDriver");
            String url = context.getInitParameter("dbUrl");
            String user = context.getInitParameter("dbUser");
            String password = context.getInitParameter("dbPassword");
            Class.forName(driver);
            connection = DriverManager.getConnection(url, user, password);
            relativeOutputFolder = getServletContext().getInitParameter("outputPath");
            newFiles = new ArrayList<>();
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
            throw new UnavailableException("Can't load database driver");
        } catch (SQLException e) {
            e.printStackTrace();
            throw new UnavailableException("Couldn't get db connection");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        user = (User) req.getSession().getAttribute("user");

        // Check param validity and return its value if ok
        Function<String, String> getParam = (paramName) -> {
            String paramValue = req.getParameter(paramName);
            if (paramValue == null || paramValue.isEmpty()) {
                throw new ClientErrorException("Missing " + paramName, Response.Status.BAD_REQUEST);
            }
            return paramValue;
        };

        // Initialize track
        try {
            String title = getParam.apply("title");
            String artist = getParam.apply("artist");
            int year;
            try {
                year = Integer.parseInt(req.getParameter("year"));
            } catch (NumberFormatException e) {
                resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid year");
                return;
            }
            if (year < 1901 || year > 2155) {
                resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid year");
                return;
            }
            String album = getParam.apply("album");
            String genre = getParam.apply("genre");
            String imagePath = processPart(req.getPart("image"), "image");
            String songPath = processPart(req.getPart("musicTrack"), "audio");
            track = new Track(0, title, artist, year, album, genre, imagePath, songPath, songHash, imageHash);
        } catch (ClientErrorException | InternalServerErrorException e) {
            resp.sendError(e.getResponse().getStatus(), e.getMessage());
            return;
        } catch (SQLException e) {
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            return;
        }

        // Add track
        TrackDAO trackDAO = new TrackDAO(connection);
        try {
            trackDAO.addTrack(track, user);
            resp.sendRedirect(getServletContext().getContextPath() + "/HomePage");
        } catch (SQLIntegrityConstraintViolationException e) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Duplicate track");
            // Delete newly created files if addTrack fails
            newFiles.forEach(file -> file.delete());
        } catch (SQLException e) {
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            newFiles.forEach(file -> file.delete());
            e.printStackTrace();
        } finally {
            newFiles.clear();
        }
    }

    /**
     * @param part     item received with the form
     * @param mimeType expected MIME type
     * @return String containing the file path of the received item; in case of errors, null is returned
     * @throws IOException
     */
    private String processPart(Part part, String mimeType) throws IOException, SQLException {
        String relativeFilePath = null;
        // Check item size
        if (part == null || part.getSize() <= 0) {
            throw new ClientErrorException("Missing " + mimeType, Response.Status.BAD_REQUEST);
        }

        // Check MIME type
        if (!part.getContentType().startsWith(mimeType)) {
            throw new ClientErrorException("File format not permitted for " + mimeType + " type", HttpServletResponse.SC_BAD_REQUEST);
        }

        TrackDAO trackDAO = new TrackDAO(connection);

        // Save item hash and try to find existing DB entries with the same hash; if present, their file path is returned
        switch (mimeType) {
            case "audio":
                songHash = getSHA256Hash(part.getInputStream().readAllBytes());
                if (songHash != null)
                    relativeFilePath = trackDAO.isTrackFileAlreadyPresent(songHash);
                break;
            case "image":
                imageHash = getSHA256Hash(part.getInputStream().readAllBytes());
                if (imageHash != null)
                    relativeFilePath = trackDAO.isImageFileAlreadyPresent(imageHash);
                break;
        }

        if (relativeFilePath != null)
            return relativeFilePath;

        String realOutputFolder = context.getRealPath(relativeOutputFolder) + File.separator + mimeType + File.separator;
        String filename = Paths.get(part.getSubmittedFileName()).getFileName().toString();
        String realOutputFilePath = realOutputFolder + UUID.randomUUID() + filename.substring(filename.lastIndexOf('.'));
        File folder = new File(realOutputFolder);

        // Try to create the output folder if it doesn't already exist
        if (!folder.exists())
            if (!folder.mkdirs()) {
                throw new ServerErrorException("Error while saving file", HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            }

        File outputFile = new File(realOutputFilePath);

        // Write the received item on disk
        try {
            Files.copy(part.getInputStream(), outputFile.toPath());
            newFiles.add(outputFile);
            relativeFilePath = relativeOutputFolder + File.separator + mimeType + File.separator + outputFile.getName();
            return relativeFilePath;
        } catch (Exception e) {
            e.printStackTrace();
            throw new ServerErrorException("Error while saving file", HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }

    }

    /**
     * @param input Array of bytes
     * @return 64 character hexadecimal String containing the SHA-256 hash of the input
     */
    private String getSHA256Hash(byte[] input) {
        MessageDigest digest;
        HexFormat hex = HexFormat.of();
        try {
            digest = MessageDigest.getInstance("SHA-256");
        } catch (NoSuchAlgorithmException e) {
            return null;
        }
        byte[] hash = digest.digest(input);
        return hex.formatHex(hash);
    }
}