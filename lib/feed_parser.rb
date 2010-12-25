class FeedParser

  # +content+ is a string, content from The Pirate Bay music RSS feed.
  #
  # Returns an array of hashes, with keys :title, :published_at, :guid, :link.
  #
  def self.parse_tpb_feed(content)
    doc = Nokogiri::XML(content)

    items = []
    doc.xpath("//item").each do |i|
      items << parse_tpb_item(i)
    end

    items
  end

  # +item+ is a Nokogiri::Node
  #
  # Returns a hash with keys :title, :published_at, :guid, :link.
  #
  def self.parse_tpb_item(item)
    {
      :title => item./("title").text,
      :published_at => item./("pubDate").text,
      :guid => item./("guid").text,
      :link => item./("link").text
    }
  end

end
