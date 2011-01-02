class Interest < ActiveRecord::Base

  belongs_to :user
  belongs_to :artist

  validates_presence_of :user_id, :score, :artist_name

end
