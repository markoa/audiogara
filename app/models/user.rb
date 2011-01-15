require 'last_fm'

class User < ActiveRecord::Base

  has_one :profile_job, :dependent => :destroy

  has_many :interests, :dependent => :destroy

  validates_presence_of :lastfm_username
  validates_uniqueness_of :lastfm_username

  MIN_SIMILARITY = 0.43

  def to_param
    self.lastfm_username
  end

  # +artists+: either a string array of artist names, or an array of hashes
  # with keys :score and :name. The former assumes score 1 and is intended
  # to be used with artist names from the listening history; the latter
  # with artist names and scores as returned by LastFm::Artist.get_similar.
  #
  def create_interests(artists)

    names = []
    codes = []
    names_and_scores = []

    item = artists.first

    if item.is_a? String
      names_and_scores = artists.map { |a| [a, 1] }

    elsif item.is_a? Hash
      names_and_scores = artists.select { |a| a[:score].to_f >= MIN_SIMILARITY }.map { |a| [ a[:name], a[:score].to_f ] }

    elsif item.is_a? SimilarArtist
      names_and_scores = artists.select { |a| a.score >= MIN_SIMILARITY }.map { |a| [a.name, a.score] }
    end

    names = names_and_scores.map { |ns| ns.first }
    codes = names.map { |name| Artist.codify(name) }

    artists = Artist.where(:code => codes).select("id, code")
    interests = self.interests.where(:artist_name => names).select("artist_name")

    Interest.transaction do
      names_and_scores.each_with_index do |item, i|
        name = item.first
        next if interests.select { |interest| interest.artist_name == name }.present? or name.blank?

        score = item.second
        artist = artists.select { |a| a.code == codes[i] }.first

        self.interests.create(
          :score => score,
          :artist_name => name,
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

  def update_profile_from_hash(hash)
    hash[:lastfm_id] = hash.delete(:id)
    update_attributes(hash)
  end

end
