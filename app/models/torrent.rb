require 'title_parser'

class Torrent < ActiveRecord::Base

  belongs_to :artist

  validates_presence_of :title, :guid, :link, :published_at
  validates_uniqueness_of :guid

  def self.create_from_hash(hash)
    artist_and_album = TitleParser.parse(hash[:title])
    return nil if artist_and_album.empty?

    create(:title => hash[:title],
           :guid => hash[:guid],
           :link => hash[:link],
           :published_at => Time.parse(hash[:published_at]),
           :artist_name => artist_and_album[:artist],
           :album_name => artist_and_album[:album])
  end
end
