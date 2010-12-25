
require 'net/http'
require 'open-uri'
require 'feed_parser'

class FeedFetcher

  TPB_MUSIC_FEED = "http://rss.thepiratebay.org/101"

  def self.fetch_tpb
    Net::HTTP.get(URI.parse(TPB_MUSIC_FEED))
  end
  
  def self.fetch_and_save_torrents_from_tpb
    feed_content = fetch_tpb
    data = FeedParser.parse_tpb_feed(feed_content)

    data.each do |item|
      next if Torrent.exists?(:link => item[:link])
      Torrent.create_from_hash(item)
    end
  end

end
