class Interest < ActiveRecord::Base

  USEFULNESS_THRESHOLD = 100 # min number of known interests for this app to be useful

  belongs_to :user
  belongs_to :artist

  validates_presence_of :user_id, :score, :artist_name

  validates_uniqueness_of :artist_name, :scope => :user_id

  scope :waiting_for_artist, lambda { |artist_name|
    where(["lower(artist_name) = ? and artist_id is null", artist_name.downcase])
  }

  scope :known, where("artist_id is not null")

end
