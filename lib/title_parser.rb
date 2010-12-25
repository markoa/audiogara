class TitleParser

  include ActiveSupport::Inflector

  def self.parse(t)
    parts = t.split("-").map(&:strip)

    return {} if parts.size == 1

    artist = remove_junk_from parts[0]
    album = remove_junk_from parts[1]
    
    # album may be in one of the parts after the second
    if album.blank? and parts.size > 2
      2.upto(parts.size-1).each do |i|
        album = remove_junk_from parts[i]
        break if album.present?
      end
    end

    return {} if artist.size == 0 or album.size == 0
    return {} if ["va", "various artists"].include?(artist)
    return {} if artist.include?("collection")
    return {} if album.include?("soundtrack")
    return {} if album.include?("discography")
    return {} if album.include?("ultimate collection")

    { :artist => artist.titleize, :album => album.titleize }
  end

  protected

  def self.remove_junk_from(t)
    tmp = t

    # if there's a parenthesis, remove everything starting from its position
    ["(", "[", "{"].each do |parenthesis|
      pos = tmp.index(parenthesis)
      tmp = tmp.slice(0, pos) if not pos.nil?
    end

    # replace h4cky whitespace
    [".", "_"].each do |ugly_separator|
      tmp.gsub!(ugly_separator, " ")
    end

    # omit year
    tmp.gsub!(/\d\d\d\d/, "")

    tmp.strip.downcase
  end

end
