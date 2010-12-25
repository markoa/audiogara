class Torrent < ActiveRecord::Base

  validates_presence_of :title, :guid, :link, :published_at
  validates_uniqueness_of :guid
end
