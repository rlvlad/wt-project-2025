package it.polimi.tiw25.pure_html.entities;

/**
 * Class that represents a single track.
 */
public record Track(
        int id,
        String title,
        String artist,
        int year,
        String album_title,
        String genre,
        String image_path,
        String song_path,
        String song_checksum,
        String image_checksum
) {
}
