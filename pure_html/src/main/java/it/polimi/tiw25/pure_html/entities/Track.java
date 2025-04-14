package it.polimi.tiw25.pure_html.entities;

/**
 * Class that represents a single track.
 */
public class Track {
    private int id;
    private String title;
    private String artist;
    private String album_title;
    private int album_release_date;
    private int album_image_path;
    private int track_path;

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getArtist() {
        return artist;
    }

    public void setArtist(String artist) {
        this.artist = artist;
    }

    public String getAlbum_title() {
        return album_title;
    }

    public void setAlbum_title(String album_title) {
        this.album_title = album_title;
    }

    public int getAlbum_release_date() {
        return album_release_date;
    }

    public void setAlbum_release_date(int album_release_date) {
        this.album_release_date = album_release_date;
    }

    public int getAlbum_image_path() {
        return album_image_path;
    }

    public void setAlbum_image_path(int album_image_path) {
        this.album_image_path = album_image_path;
    }

    public int getTrack_path() {
        return track_path;
    }

    public void setTrack_path(int track_path) {
        this.track_path = track_path;
    }

    @Override
    public String toString() {
        return "Track{" +
                "id=" + id +
                ", title='" + title + '\'' +
                ", artist='" + artist + '\'' +
                ", album_title='" + album_title + '\'' +
                ", album_release_date=" + album_release_date +
                ", album_image_path=" + album_image_path +
                ", track_path=" + track_path +
                '}';
    }
}
