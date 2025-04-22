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

import java.io.File;
import java.io.IOException;
import java.io.Serial;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.sql.*;
import java.util.ArrayList;
import java.util.HexFormat;
import java.util.List;
import java.util.UUID;

@WebServlet("/UploadTrack")
@MultipartConfig
public class UploadTrack extends HttpServlet {
    @Serial
    private static final long serialVersionUID = 1L;
    private Connection connection = null;
    String projectPath;
    String imageHash;
    String songHash;
    User user;
    Track track;
    List<File> newFiles;

    public void init() throws ServletException {
        try {
            ServletContext context = getServletContext();
            String driver = context.getInitParameter("dbDriver");
            String url = context.getInitParameter("dbUrl");
            String user = context.getInitParameter("dbUser");
            String password = context.getInitParameter("dbPassword");
            Class.forName(driver);
            connection = DriverManager.getConnection(url, user, password);
            projectPath = getServletContext().getInitParameter("outputPath");
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

        // Initialize track
        String songPath = processPart(req.getPart("musicTrack"), "audio", resp);
        String imagePath = processPart(req.getPart("image"), "image", resp);
        if (songPath == null || imagePath == null)
            return;
        String title = req.getParameter("title");
        String artist = req.getParameter("artist");
        String album = req.getParameter("album");
        int year = Integer.parseInt(req.getParameter("year"));
        String genre = req.getParameter("genre");
        track = new Track(0, title, artist, year, album, genre, imagePath, songPath, songHash, imageHash);

        // Try to add track
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
            e.printStackTrace();
        } finally {
            newFiles.clear();
        }
    }

    /**
     * @param part     item received with the form
     * @param mimeType expected MIME type
     * @param resp     HTTP response, used for error handling
     * @return String containing the file path of the received item; in case of errors, null is returned
     * @throws IOException
     */
    private String processPart(Part part, String mimeType, HttpServletResponse resp) throws IOException {
        // Check item size
        if (part == null || part.getSize() <= 0) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing " + mimeType);
            return null;
        }

        // Check MIME type
        if (!part.getContentType().startsWith(mimeType)) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "File format not permitted for " + mimeType + " type");
            return null;
        }

        TrackDAO trackDAO = new TrackDAO(connection);
        String alreadyPresentPath = null;

        // Save item hash and try to find existing DB entries with the same hash; if present, their file path is returned
        try {
            switch (mimeType) {
                case "audio":
                    songHash = getSHA256Hash(part.getInputStream().readAllBytes());
                    if (songHash != null)
                        alreadyPresentPath = trackDAO.isTrackFileAlreadyPresent(songHash);
                    break;
                case "image":
                    imageHash = getSHA256Hash(part.getInputStream().readAllBytes());
                    if (imageHash != null)
                        alreadyPresentPath = trackDAO.isImageFileAlreadyPresent(imageHash);
                    break;
            }
        } catch (SQLException e) {
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            e.printStackTrace();
            return null;
        }

        if (alreadyPresentPath != null)
            return alreadyPresentPath;

        String outputFolder = System.getProperty("user.home") + "/" + projectPath + mimeType + "/";
        String filename = Paths.get(part.getSubmittedFileName()).getFileName().toString();
        String outputPath = outputFolder + UUID.randomUUID() + "-" + filename;
        File folder = new File(outputFolder);

        // Try to create the output folder if it doesn't already exist
        if (!folder.exists())
            if (!folder.mkdirs()) {
                resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error while saving file");
                return null;
            }

        File file = new File(outputPath);
        newFiles.add(file);

        // Write the received item on disk
        try {
            Files.copy(part.getInputStream(), file.toPath());
            return outputPath;
        } catch (Exception e) {
            e.printStackTrace();
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error while saving file");
            e.printStackTrace();
            return null;
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
