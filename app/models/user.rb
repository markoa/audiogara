class User < ActiveRecord::Base

  has_many :interests

  validates_presence_of :lastfm_username

end
