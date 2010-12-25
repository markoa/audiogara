module LastFm

  API_KEY = ENV['AUDIOGARA_LASTFM_API_KEY']

  class Artist

    # Fetches artist info.
    # http://www.last.fm/api/show?service=267
    #
    # pass +content+ in test env to avoid API call
    #
    def self.get_info(artist, content = nil)
      content ||= LastFm::fetch("http://ws.audioscrobbler.com/2.0/?method=artist.getinfo&artist=#{LastFm::escape(artist)}")

      doc = Nokogiri::XML(content)
      h = {}

      return h if doc./("lfm[status=failed]").present?

      h[:name] = doc./("name").first.text
      h[:mbid] = doc./("mbid").text
      h[:url] = doc./("url").first.text
      h[:image_small] = doc./("image[size=small]").first.text
      h[:image_medium] = doc./("image[size=medium]").first.text
      h[:image_large] = doc./("image[size=large]").first.text
      h[:image_extralarge] = doc./("image[size=extralarge]").first.text
      h[:image_mega] = doc./("image[size=mega]").first.text
      h
    end

    # Fetches similar artists.
    # http://ws.audioscrobbler.com/2.0/artist/MGMT/similar.txt
    #
    # pass +content+ in test env to avoid API call
    #
    def self.get_similar(artist, content = nil)
      content ||= LastFm::fetch("http://ws.audioscrobbler.com/2.0/artist/#{LastFm::escape(artist)}/similar.txt")
      res = []

      return res if content.empty?

      content.split("\n").each do |line|
        parts = line.split(',')
        res << {
          :score => parts.first.to_f,
          :mbid => parts.second,
          :name => parts.third
        }
      end

      res
    end
  end

  protected

  def self.fetch(path)
    Net::HTTP.get(URI.parse("#{path}&api_key=#{API_KEY}"))
  end

  def self.escape(data)
    URI.escape(data.gsub(/\s/, '+'))
  end
end
