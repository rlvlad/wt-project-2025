package it.polimi.tiw25.pure_html.entities;

/**
 * Class that represents a Playlist.
 */
public class Playlist {
    private int id;
    private String title;
    private int creation_date;
    private User user;

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

    public int getCreation_date() {
        return creation_date;
    }

    public void setCreation_date(int creation_date) {
        this.creation_date = creation_date;
    }

    public User getUser() {
        return user;
    }

    public void setUser(User user) {
        this.user = user;
    }

    @Override
    public String toString() {
        return "Playlist{" +
                "id=" + id +
                ", title='" + title + '\'' +
                ", creation_date=" + creation_date +
                ", user='" + user + '\'' +
                '}';
    }
}
