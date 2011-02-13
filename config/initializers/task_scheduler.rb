require 'feed_fetcher'

scheduler = Rufus::Scheduler.start_new

scheduler.every "20m"  do
  FeedFetcher.fetch_and_save_torrents_from_tpb
  FeedFetcher.fetch_and_save_torrents_from_demonoid
  Torrent.process_artists
  Artist.fetch_similar_artists
  SimilarArtist.link_with_known_artists
  Torrent.trim
end

scheduler.every "1m" do
  ProfileJob.process_all
end
