class FeedParser

  DEMONOID_URL_PREFIX = "http://www.demonoid.me"

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

  def self.parse_demonoid_page(content)
    doc = Nokogiri::HTML(content)
    items = []

    ["td.tone_1_pad", "td.tone_3_pad"].each do |row_kind|
      doc.css(row_kind).each do |title_row|
        items << parse_demonoid_rows(title_row, title_row.parent.next)
      end
    end

    items
  end

  def self.parse_demonoid_rows(title_row, meta_row)
    return {
      :title => title_row.children.first.inner_text.strip,
      :guid => DEMONOID_URL_PREFIX + title_row.css("a").first.attributes["href"].to_s.strip,
      :link => DEMONOID_URL_PREFIX + meta_row.css("img[title='Download torrent']").first.parent.attributes["href"].to_s.strip,
      :published_at => Time.now.to_s
    }
  end

end
