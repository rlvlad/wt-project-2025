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

@WebServlet("/UploadTrack")
@MultipartConfig
public class UploadTrack extends HttpServlet {
    @Serial
    private static final long serialVersionUID = 1L;
    private Connection connection = null;
    String relativeOutputPath;
    String imageHash;
    String songHash;
    User user;
    Track track;
    List<File> newFiles;
    ServletContext context;

    public void init() throws ServletException {
        try {
            context = getServletContext();
            String driver = context.getInitParameter("dbDriver");
            String url = context.getInitParameter("dbUrl");
            String user = context.getInitParameter("dbUser");
            String password = context.getInitParameter("dbPassword");
            Class.forName(driver);
            connection = DriverManager.getConnection(url, user, password);
            relativeOutputPath = getServletContext().getInitParameter("outputPath");
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
        String title = req.getParameter("title");
        if (title == null || title.isEmpty()) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing title");
            return;
        }
        String artist = req.getParameter("artist");
        if (artist == null || artist.isEmpty()) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing artist");
            return;
        }
        String album = req.getParameter("album");
        if (album == null || album.isEmpty()) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing album");
            return;
        }
        int year;
        try {
            year = Integer.parseInt(req.getParameter("year"));
        } catch (NumberFormatException e) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid year");
            return;
        }
        if (year < 1901 || year > 2155) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid year");
        }
        String genre = req.getParameter("genre");
        if (genre == null || genre.isEmpty()) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing genre");
            return;
        }
        String songPath;
        String imagePath;
        try {
            songPath = processPart(req.getPart("musicTrack"), "audio");
            imagePath = processPart(req.getPart("image"), "image");
        } catch (ClientErrorException | InternalServerErrorException e) {
            resp.sendError(e.getResponse().getStatus(), e.getMessage());
            return;
        } catch (SQLException e) {
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            return;
        }

        track = new Track(0, title, artist, year, album, genre, imagePath, songPath, songHash, imageHash);

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
        // Check item size
        if (part == null || part.getSize() <= 0) {
            throw new ClientErrorException("Missing " + mimeType, Response.Status.BAD_REQUEST);
        }

        // Check MIME type
        if (!part.getContentType().startsWith(mimeType)) {
            throw new ClientErrorException("File format not permitted for " + mimeType + " type", HttpServletResponse.SC_BAD_REQUEST);
        }

        TrackDAO trackDAO = new TrackDAO(connection);
        String alreadyPresentPath = null;

        // Save item hash and try to find existing DB entries with the same hash; if present, their file path is returned
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

        if (alreadyPresentPath != null)
            return alreadyPresentPath;

        String outputFolder = context.getRealPath(relativeOutputPath) + "/" + mimeType + "/";
        String filename = Paths.get(part.getSubmittedFileName()).getFileName().toString();
        String outputPath = outputFolder + UUID.randomUUID() + "-" + filename;
        File folder = new File(outputFolder);

        // Try to create the output folder if it doesn't already exist
        if (!folder.exists())
            if (!folder.mkdirs()) {
                throw new ServerErrorException("Error while saving file", HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            }

        File file = new File(outputPath);
        newFiles.add(file);

        // Write the received item on disk
        try {
            Files.copy(part.getInputStream(), file.toPath());
            return relativeOutputPath + "/" + mimeType + "/" + file.getName();
        } catch (Exception e) {
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