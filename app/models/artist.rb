class Artist < ActiveRecord::Base

  has_many :torrents

  has_many :similar_artists, :foreign_key => "parent_artist_id"

  validates_presence_of :name
  validates_presence_of :lastfm_url

  def self.create_from_hash(hash)
    return nil if hash.empty?

    create(:name => hash[:name],
           :mbid => hash[:mbid],
           :lastfm_url => hash[:url],
           :image_small_url => hash[:image_small],
           :image_medium_url => hash[:image_medium],
           :image_large_url => hash[:image_large],
           :image_extralarge_url => hash[:image_extralarge],
           :image_mega_url => hash[:image_mega])
  end

end
