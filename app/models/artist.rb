class Artist < ActiveRecord::Base

  has_many :torrents

  validates_presence_of :name
  validates_presence_of :lastfm_url

end
