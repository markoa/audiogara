require 'feed_fetcher'

scheduler = Rufus::Scheduler.start_new

scheduler.every "20m"  do
  FeedFetcher.fetch_and_save_torrents_from_tpb
end
