
require 'net/http'
require 'open-uri'
require 'feed_parser'

class FeedFetcher

  TPB_MUSIC_FEED = "http://rss.thepiratebay.org/101"
  DEMONOID_MUSIC_PAGE = "http://www.demonoid.me/files/?category=2"

  def self.fetch_tpb
    Net::HTTP.get(URI.parse(TPB_MUSIC_FEED))
  end

  def self.fetch_demonoid_page
    Net::HTTP.get(URI.parse(DEMONOID_MUSIC_PAGE))
  end
  
  def self.fetch_and_save_torrents_from_tpb
    feed_content = fetch_tpb
    data = FeedParser.parse_tpb_feed(feed_content)

    data.each do |item|
      next if Torrent.exists?(:link => item[:link])
      Torrent.create_from_hash(item, Torrent::SOURCE_TPB)
    end
  end

  def self.fetch_and_save_torrents_from_demonoid
    content = fetch_demonoid_page
    data = FeedParser.parse_demonoid_page(content)

    data.each do |item|
      next if Torrent.exists?(:link => item[:link])
      Torrent.create_from_hash(item, Torrent::SOURCE_DEMONOID)
    end
  end

end
