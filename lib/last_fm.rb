module LastFm

  API_KEY = ENV['AUDIOGARA_LASTFM_API_KEY']

  class Artist

    # Fetches artist info.
    # http://www.last.fm/api/show?service=267
    #
    # pass +content+ in test env to avoid API call
    #
    def self.get_info(artist)
      content = LastFm::fetch("http://ws.audioscrobbler.com/2.0/?method=artist.getinfo&artist=#{LastFm::escape(artist)}")

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
      h.keys.each { |k| h[k].strip! }
      h
    end

    # Fetches similar artists.
    # http://ws.audioscrobbler.com/2.0/artist/MGMT/similar.txt
    #
    # Returns an array of hashes with keys: :score, :mbid, :name.
    #
    def self.get_similar(artist)
      content = LastFm::fetch("http://ws.audioscrobbler.com/2.0/artist/#{LastFm::escape(artist)}/similar.txt")
      res = []

      return res if content.empty?

      content.split("\n").each do |line|
        parts = line.split(',')
        name = parts.third
        name = CGI.unescapeHTML(name) unless name.blank?

        res << {
          :score => parts.first.to_f,
          :mbid => parts.second,
          :name => name
        }
      end

      res
    end
  end

  class User

    PERIODS = ["overall", "7day", "3month", "6month", "12month"]

    # Gets artists that appear in any of the +username+'s top lists,
    # returns an array of strings.
    #
    def self.get_top_artists(username, options = {})

      base_url = "http://ws.audioscrobbler.com/2.0/?method=user.getTopArtists&user=#{username}"
      results = []
      options[:periods] ||= PERIODS

      options[:periods].each do |period|

        content = LastFm::fetch(base_url + "&period=#{period}")
        doc = Nokogiri::XML(content)

        next if doc./("lfm[status=failed]").present?

        doc./("name").each do |node|
          results << node.text unless results.include?(node.text)
        end
      end

      results
    end

    # Gets information about a user profile, returns a hash.
    #
    # http://www.last.fm/api/show?service=344
    #
    def self.get_info(username)
      content = LastFm::fetch("http://ws.audioscrobbler.com/2.0/?method=user.getInfo&user=#{username}")
      doc = Nokogiri::XML(content)

      if doc./("lfm[status=failed]").present?
        return { :error => doc./("error").text }
      end

      h = {}
      ["id", "name", "realname", "url", "country", "age", "gender", "playcount"].each do |key|
        h[key.to_sym] = doc./(key).first.text.strip
      end

      h[:image_small] = doc./("image[size=small]").first.text
      h[:image_medium] = doc./("image[size=medium]").first.text
      h[:image_large] = doc./("image[size=large]").first.text
      h[:image_extralarge] = doc./("image[size=extralarge]").first.text
      h[:registered] = Date.parse(doc./("registered").first.text).to_s
      h
    end
  end

  protected

  def self.fetch(path)
    begin
      path = URI.parse("#{path}&api_key=#{API_KEY}")
      Net::HTTP.get(path)
    rescue EOFError
      puts "EOFError while GET-ing '#{path}'"
      ""
    end
  end

  def self.escape(data)
    URI.escape(data.gsub(/\s/, '+'))
  end
end
