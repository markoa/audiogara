
namespace :migrate do    

  desc 'Assigns source of all torrents to tpb (after introduction of #source)'
  task :assign_all_torrents_to_tpb => :environment do
    Torrent.find_each do |torrent|
      torrent.update_attribute(:source, Torrent::SOURCE_TPB)
    end
  end
end
