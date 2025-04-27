package it.polimi.tiw25.pure_html.entities;

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
        String image_checksum
) implements Comparable<Track> {
    @Override
    public int compareTo(Track track) {
        int artistComparison;
        int yearComparison;
        if ((artistComparison = this.artist().compareTo(track.artist())) == 0)
            if ((yearComparison = this.year.compareTo(track.year)) == 0)
                return this.title.compareTo(track.title);
            else
                return yearComparison;
        else return artistComparison;
    }
}

