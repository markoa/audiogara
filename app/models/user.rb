class User < ActiveRecord::Base

  has_many :interests

  validates_presence_of :lastfm_username

  # Creates Interests based on names of artists from the listening history;
  # those will have a score of 1.
  #
  # Param: a string array of artist names.
  #
  def create_top_interests(artist_names)

    artist_names.each do |name|

      next if self.interests.exists?(:artist_name => name)

      interest = self.interests.build(
        :score => 1,
        :artist_name => name,
        :artist => Artist.named(name)
      )

      interest.save!
    end
  end

end
