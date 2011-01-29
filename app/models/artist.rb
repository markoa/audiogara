require 'last_fm'

class Artist < ActiveRecord::Base

  has_many :torrents

  has_many :similar_artists,
    :foreign_key => "parent_artist_id",
    :dependent => :destroy

  validates_presence_of :name
  validates_presence_of :lastfm_url

  validates_uniqueness_of :name

  before_validation :generate_code, :on => :create

  after_create :assign_to_waiting_interests
  before_destroy :unassign_from_interests

  scope :need_update_of_similar_artists, lambda {
    where(["similars_processed_at is null or similars_processed_at <= ?", 1.month.ago])
  }

  cattr_reader :per_page
  @@per_page = 50

  MIN_SIMILARITY = 0.43

  # A shortcut to do a case insensitive find by name.
  #
  # Returns an array of Artists if found.
  #
  def self.named(name)
    where(["lower(name) = ?", name.downcase])
  end

  # Returns an Artist if found, nil if not.
  #
  def self.codename(code)
    where(:code => code).first
  end

  # Creates a new record from a hash as returned by LastFm::Artist.get_info.
  #
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

  def assign_to_waiting_interests
    Interest.waiting_for_artist(self.name).find_each do |interest|
      interest.update_attribute(:artist_id, self.id)
    end
  end

  def unassign_from_interests
    Interest.where(:artist_id => self.id).find_each do |interest|
      interest.update_attribute(:artist_id, nil)
    end
  end

  # +sims+ is an array of hashes as returned by LastFm::Artist.get_similar.
  #
  def update_similar_artists(sims)
    sims.each do |hash|
      sim = self.similar_artists.where(:name => hash[:name]).first

      if sim.present?
        sim.update_attributes(
          :score => hash[:score],
          :mbid => hash[:mbid]
        )
      else
        self.similar_artists.create(
          :name => hash[:name],
          :score => hash[:score],
          :mbid => hash[:mbid]
        )
      end
    end

    update_attribute(:similars_processed_at, Time.now)
  end

  # the job
  #
  def self.fetch_similar_artists
    Artist.need_update_of_similar_artists.each do |artist|
      sims = LastFm::Artist.get_similar(artist.name)
      artist.update_similar_artists(sims)
    end
  end

  def self.codify(name)
    return nil if name.nil?
    name.downcase.gsub(/\s/, '')
  end

  def generate_code
    self.code = Artist.codify(self.name)
  end

end
