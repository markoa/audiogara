require 'last_fm'

class User < ActiveRecord::Base

  has_one :profile_job, :dependent => :destroy

  has_many :interests, :dependent => :destroy

  has_many :ignored_artists, :dependent => :destroy

  validates_presence_of :lastfm_username, :lastfm_id
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

    artist_interests = ArtistInterest.factory(artists)

    names = artist_interests.map { |ai| ai.name }
    codes = artist_interests.map { |ai| ai.code }

    # group these for to reduce the number of queries
    known_artists = Artist.where(:code => codes).select("id, code")
    ignored_artists = self.ignored_artists.collect { |ia| ia.artist }.collect { |a| a.name }
    known_interests = self.interests.where(:artist_name => names).select("artist_name").collect { |i| i.artist_name }

    Interest.transaction do
      artist_interests.each do |ai|
        next if ai.name.blank?
        next if ignored_artists.include?(ai.name)
        next if known_interests.include?(ai.name)

        artist = known_artists.select { |a| a.code == ai.code }.first

        self.interests.create(
          :score => ai.score,
          :artist_name => ai.name,
          :artist => artist
        )
      end
    end
  end

  def build_profile
    top_artists = LastFm::User.get_top_artists(self.lastfm_username)
    create_interests(top_artists)

    top_artist_names = top_artists.map { |a| a.downcase }

    artists = Artist.where(["lower(\"artists\".\"name\") in (?)", top_artist_names]).
      select("id, name").
      includes(:similar_artists)

    similars_from_net = []
    similars_from_db = []

    top_artists.each do |name|
      artist = artists.select { |a| a.name == name }.first
      if artist.present?
        similar_artists = artist.similar_artists
      else
        similar_artists = LastFm::Artist.get_similar(name)
      end

      if similar_artists.first.is_a?(Hash)
        similars_from_net = similars_from_net + similar_artists
      elsif similar_artists.first.is_a?(SimilarArtist)
        similars_from_db = similars_from_db + similar_artists
      end
    end

    create_interests(similars_from_net)
    create_interests(similars_from_db)
  end

  def rebuild_profile
    top_artists = LastFm::User.get_top_artists(self.lastfm_username)
    create_interests(top_artists)
  end

  def interesting_torrents
    aids = self.interests.known.collect { |i| i.artist_id }
    Torrent.where(:artist_id => aids).includes(:artist).order("created_at DESC")
  end

  def profile_pending?
    profile_job.present? and not profile_job.done?
  end

  # Updates last.fm profile attributes from the +hash+ returned from
  # LastFm::User.get_info.
  #
  def update_profile_from_hash(hash)
    hash[:lastfm_id] = hash.delete(:id)
    update_attributes(hash)
  end
  
end
