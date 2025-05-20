package it.polimi.tiw25.js.entities;

/**
 * Class that represents a single track.
 */
public record Track(
        int id,
        String title,
        String artist,
        Integer year,
        String album_title,
        String genre,
        String image_path,
        String song_path,
        String song_checksum,
        String image_checksum,
        int custom_ordering
) {
    /**
     * Track constructor without custom_ordering.
     *
     * @param id track id
     * @param title track title
     * @param artist track artist
     * @param year track year
     * @param album_title track album_title
     * @param genre track genre
     * @param image_path track image_path
     * @param song_path track song_path
     * @param song_checksum track song_checksum
     * @param image_checksum track image_checksum
     */
    public Track(
            int id,
            String title,
            String artist,
            Integer year,
            String album_title,
            String genre,
            String image_path,
            String song_path,
            String song_checksum,
            String image_checksum
    ) {
        this(id, title, artist, year, album_title, genre, image_path, song_path, song_checksum, image_checksum, 0);
    }
}

