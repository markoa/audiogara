class Interest < ActiveRecord::Base

  belongs_to :user
  belongs_to :artist

  validates_presence_of :user_id, :score, :artist_name

  validates_uniqueness_of :artist_name, :scope => :user_id

  scope :waiting_for_artist, lambda { |artist_name|
    where(["lower(artist_name) = ? and artist_id is null", artist_name.downcase])
  }

end
