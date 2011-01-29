
# Intermediate object, representing a User's interest in an artist,
# either from the listening history charts, similar artist API or
# similar artists in our db. Used to convert various sources of artist data
# in order to create interests and build a profile.
#
class ArtistInterest

  attr_accessor :name
  attr_accessor :score
  attr_accessor :code

  def initialize(options = {})
    options.each do |key, value|
      self.send("#{key}=", value)
    end

    self.code = Artist.codify(name)
  end

  # +artists+ is an array of strings (top artists), hashes (similar artists
  # from API) or SimilarArtist objects.
  #
  def self.factory(artists)

    names_and_scores = []
    sample = artists.first

    if sample.is_a? String
      names_and_scores = artists.map { |a| [a, 1] }

    elsif sample.is_a? Hash
      names_and_scores = artists.select { |a| a[:score].to_f >= Artist::MIN_SIMILARITY }.map { |a| [ a[:name], a[:score].to_f ] }

    elsif sample.is_a? SimilarArtist
      names_and_scores = artists.select { |a| a.score >= Artist::MIN_SIMILARITY }.map { |a| [a.name, a.score] }
    end

    artist_interests = []

    names_and_scores.each do |ns|
      artist_interests << ArtistInterest.new(:name => ns.first, :score => ns.second)
    end

    artist_interests
  end

end
