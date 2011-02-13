namespace :app do

  desc 'Deletes torrents older than two weeks'
  task :trim_torrents => :environment do
    Torrent.trim
  end
end
