# in alphabetical order

Factory.define(:artist) do |a|
  a.sequence(:name) { |i| "artist#{i}" }
  a.lastfm_url "http://last.fm/music/MGMT"
end

Factory.define(:ignored_artist) do |ia|
  ia.association :user
  ia.sequence(:name) { |i| "artist#{i}" }
end

Factory.define(:interest) do |i|
  i.association :user
  i.score 1
  i.sequence(:artist_name) { |i| "artist#{i}" }
end

Factory.define(:profile_job) do |j|
  j.association :user
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

Factory.define(:user) do |u|
  u.sequence(:lastfm_username) { |i| "user#{i}" }
  u.sequence(:lastfm_id) { |i| i }
end
