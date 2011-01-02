class User < ActiveRecord::Base

  validates_presence_of :lastfm_username

end
