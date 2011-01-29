require 'title_parser'
require 'last_fm'

class Torrent < ActiveRecord::Base

  belongs_to :artist

  validates_presence_of :title, :guid, :link, :published_at
  validates_uniqueness_of :guid

  scope :with_known_artist, :conditions => "artist_id is not null"

  scope :with_unprocessed_artist, :conditions => "artist_processed_at is null"

  cattr_reader :per_page
  @@per_page = 50

  SOURCE_TPB = 1
  SOURCE_DEMONOID = 2

  def self.create_from_hash(hash, source)
    artist_and_album = TitleParser.parse(hash[:title])
    return nil if artist_and_album.empty?

    create(:title => hash[:title],
           :guid => hash[:guid],
           :link => hash[:link],
           :published_at => Time.parse(hash[:published_at]),
           :artist_name => artist_and_album[:artist],
           :album_name => artist_and_album[:album],
           :source => source)
  end

  # +fetcher+ is used in test env only
  #
  def self.process_artists(fetcher = nil)
    fetcher ||= LastFm::Artist

    with_unprocessed_artist.each do |torrent|

      artist = Artist.named(torrent.artist_name).first

      if artist.nil?
        hash = fetcher.get_info(torrent.artist_name)
        artist = Artist.create_from_hash(hash)
      end

      torrent.artist = artist
      torrent.artist_processed_at = Time.now
      torrent.save
    end
  end

  def destroy_with_artist
    if self.artist_id.present? and self.artist.torrents.count == 1
      self.artist.destroy
    end

    self.destroy
  end

  def self.destroy_older_than(timestamp)
    Torrent.find_each(:conditions => ["created_at <= ?", timestamp]) do |torrent|
      torrent.destroy_with_artist
    end
  end

  # Destroys torrents older than two weeks and those with an unknown artist.
  #
  def self.trim
    Torrent.destroy_older_than(2.weeks.ago)

    # remember to give a chance to the unprocessed
    Torrent.find_each(:conditions => ["artist_id is null and created_at <= ?", 30.minutes.ago]) do |torrent|
      torrent.destroy
    end
  end

end
