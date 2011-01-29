namespace :app do

  desc 'Deletes torrents older than two weeks'
  task :delete_old_torrents => :environment do
    Torrent.destroy_older_than(2.weeks.ago)
  end
end
