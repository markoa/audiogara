class SimilarArtist < ActiveRecord::Base

  belongs_to :artist

  belongs_to :parent_artist,
    :foreign_key => "parent_artist_id", :class_name => "Artist"

  validates_presence_of :name, :score

  scope :known, :conditions => "artist_id is not null"

  def self.link_with_known_artists
    find_each(:conditions => "artist_id is null") do |sa|
      artist = Artist.find_by_name(sa.name)
      sa.update_attribute(:artist_id, artist.id) if artist.present?
    end
  end

end
