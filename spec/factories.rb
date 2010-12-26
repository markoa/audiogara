# in alphabetical order

Factory.define(:artist) do |a|
  a.name "MGMT"
  a.lastfm_url "http://last.fm/music/MGMT"
end

Factory.define(:similar_artist) do |s|
  s.name "MGMT"
  s.score 0.9
end

Factory.define(:torrent) do |t|
  t.title "MGMT - Congratulations"
  t.sequence(:guid) { |i| "http://thepiratebay.org/torrent/#{i}" }
  t.link "http://torrents.thepiratebay.org/5449179/MGMT_-_Congratulations.5449179.TPB.torrent"
  t.published_at 2.days.ago
  t.artist_name "MGMT"
  t.album_name "Congratulations"
  t.association :artist
end
