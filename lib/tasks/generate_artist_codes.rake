namespace :app do    
  desc 'Generate Artist#codes for all artists after the migration'

  task :generate_artist_codes => :environment do
    Artist.find_each do |a|
      a.generate_code
      a.save
    end
  end
end
