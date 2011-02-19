require 'last_fm'

namespace :app do    

  desc 'Delete user in db, pass USERNAME'
  task :delete_user => :environment do
    user = User.find_by_lastfm_username(ENV['USERNAME'])
    unless user.nil?
      user.destroy
      puts "user #{ENV['USERNAME']} deleted."
    end
  end

  desc "Lists all users"
  task :list_users => :environment do
    User.find_each do |user|
      puts user.lastfm_username
    end
  end

  desc "Lists all users with some stats"
  task :user_stats => :environment do
    User.find_each do |user|
      interest_count = user.interests.count
      known_interest_count = user.interests.known.count
      puts "#{user.lastfm_username}\t#{interest_count} interests\t#{known_interest_count} known"
    end
  end

  desc "Updates users' last.fm profile info"
  task :update_user_profiles => :environment do
    User.find_each do |user|
      lastfm_hash = LastFm::User.get_info(user.lastfm_username)
      if lastfm_hash.has_key?(:error)
        puts "Error while updating user #{user.lastfm_username}: #{lastfm_hash[:error]}."
        next
      end
      user.update_profile_from_hash(lastfm_hash)
    end
  end

  desc "Refreshes all user profiles"
  task :refresh_user_profiles => :environment do
    User.find_each do |user|
      user.refresh_profile
    end
  end
end
