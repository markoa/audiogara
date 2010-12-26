class SimilarArtist < ActiveRecord::Base

  belongs_to :artist

  belongs_to :parent_artist,
    :foreign_key => "parent_artist_id", :class_name => "Artist"

  validates_presence_of :name, :score

end
