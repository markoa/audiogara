class User < ActiveRecord::Base

  has_many :interests, :dependent => :destroy

  validates_presence_of :lastfm_username

  # Param: either a string array of artist names, or an array of hashes with
  # keys :score and :name. The former assumes score 1 and is intended to be
  # used with artist names from the listening history; the latter with artist
  # names and scores as returned by LastFm::Artist.get_similar.
  #
  def create_interests(artists)

    artists.each do |item|

      if item.is_a? String
        name = item
        score = 1
      elsif item.is_a? Hash
        name = item[:name]
        score = item[:score].to_f
      elsif item.is_a? SimilarArtist
        name = item.name
        score = item.score
      end

      next if self.interests.exists?(:artist_name => name)

      self.interests.create(
        :score => score,
        :artist_name => name,
        :artist => Artist.named(name)
      )
    end
  end

end
