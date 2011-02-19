require 'last_fm'

class User < ActiveRecord::Base

  has_one :profile_job, :dependent => :destroy

  has_many :interests, :dependent => :destroy

  has_many :ignored_artists, :dependent => :destroy

  has_many :hidden_releases, :dependent => :destroy

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
    ignored_artists = self.ignored_artists.collect { |ia| ia.name }
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

  def build_profile(periods = nil)
    top_artists = LastFm::User.get_top_artists(self.lastfm_username, :periods => periods)
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

  def refresh_profile
    build_profile(["7day"])
  end

  def interesting_torrents
    aids = self.interests.known.collect { |i| i.artist_id }
    torrents = Torrent.where(:artist_id => aids).includes(:artist).order("created_at DESC")

    hidden = self.hidden_releases
    torrents.delete_if { |t| hidden.select { |h| h.artist_name == t.artist_name and h.album_name == t.album_name } != [] }
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

  def ignore_artist(artist)
    interest = interests.find_by_artist_id(artist.id)
    interest.destroy if interest.present?
    ignored_artists.create(:name => artist.name)
  end

  def hide_release(torrent, reason)
    hidden_releases.create(
      :artist_name => torrent.artist_name,
      :album_name => torrent.album_name,
      :reason => reason
    )
  end

  def hide_release_as_owned(torrent)
    hide_release(torrent, HiddenRelease::REASON_OWNED)
  end

  def hide_release_as_not_interesting(torrent)
    hide_release(torrent, HiddenRelease::REASON_NOT_INTERESTED)
  end
  
end
