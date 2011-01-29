class IgnoredArtist < ActiveRecord::Base

  belongs_to :artist
  belongs_to :user

  validates_presence_of :artist_id, :user_id

end
