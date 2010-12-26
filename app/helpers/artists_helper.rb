module ArtistsHelper

  def other_similar_artists_link(artist, known_similar_artists = nil)
    if known_similar_artists.present? and not known_similar_artists.empty?
      link_to(
        pluralize(artist.similar_artists.count - known_similar_artists.count, "other"),
        artist_similar_artists_path(artist)
      )
    else
      link_to(
        pluralize(artist.similar_artists.count, "artists"),
        artist_similar_artists_path(artist)
      )
    end
  end
end
