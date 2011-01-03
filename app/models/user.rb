require 'last_fm'

class User < ActiveRecord::Base

  has_many :interests, :dependent => :destroy

  validates_presence_of :lastfm_username
  validates_uniqueness_of :lastfm_username

  def to_param
    self.lastfm_username
  end

  # +artists+: either a string array of artist names, or an array of hashes
  # with keys :score and :name. The former assumes score 1 and is intended
  # to be used with artist names from the listening history; the latter
  # with artist names and scores as returned by LastFm::Artist.get_similar.
  #
  def create_interests(artists)

    artists.each do |item|

      if item.is_a? String
        name = item
        score = 1
      elsif item.is_a? Hash
        name = item[:name]
        score = item[:score].to_f
      elsif item.is_a? SimilarArtist
        name = item.name
        score = item.score
      end

      next if self.interests.exists?(:artist_name => name) or name.blank?

      self.interests.create(
        :score => score,
        :artist_name => name,
        :artist => Artist.named(name)
      )
    end
  end

  def build_profile
    top_artists = LastFm::User.get_top_artists(self.lastfm_username)
    create_interests(top_artists)

    top_artists.each do |name|
      artist = Artist.named(name)
      if artist.present?
        similar_artists = artist.similar_artists
      else
        similar_artists = LastFm::Artist.get_similar(name)
      end

      create_interests(similar_artists)
    end
  end

  def interesting_torrents
    aids = self.interests.known.collect { |i| i.artist_id }
    artists = Artist.find(aids)
    torrents = []
    artists.each do |a|
      torrents = torrents + a.torrents
    end
    torrents
  end

end
